#!/usr/bin/env nu

# Deploy and manage a 3-node HA Kubernetes cluster on Hetzner Cloud with NixOS.
#
# Prerequisites:
#   - hcloud CLI authenticated (HCLOUD_TOKEN or hcloud context)
#   - SSH agent running with key(s) registered in the Hetzner Cloud project
#   - Nushell ≥ 0.100
#
# Usage:
#   nu deploy.nu create      # create servers + install NixOS
#   nu deploy.nu k8s-init    # bootstrap Kubernetes + Cilium
#   nu deploy.nu rebuild     # apply NixOS config changes
#   nu deploy.nu k8s-upgrade # rolling Kubernetes upgrade
#   nu deploy.nu destroy     # tear everything down

use lib/config.nu
use lib/ssh.nu
use lib/hcloud.nu
use lib/k8s.nu

# ---------------------------------------------------------------------------
# create — provision servers and install NixOS
# ---------------------------------------------------------------------------
def "main create" [] {
  print "==> Creating Hetzner Cloud servers ..."

  let keys = hcloud ssh-key-args
  for node in $config.NODES {
    let exists = try { hcloud server describe $node; true } catch { false }
    if $exists {
      print $"  ($node) already exists, skipping."
    } else {
      print $"  Creating ($node) \(($config.SERVER_TYPE) in ($config.LOCATION)\) ..."
      (hcloud server create
        --name $node
        --type $config.SERVER_TYPE
        --location $config.LOCATION
        --image $config.IMAGE
        ...$keys)
    }
  }

  print "==> All servers created. Proceeding to NixOS installation."
  main install
}

# ---------------------------------------------------------------------------
# install — (re)install NixOS on existing servers via nixos-anywhere
# ---------------------------------------------------------------------------
def "main install" [] {
  let root = config flake-root

  for node in $config.NODES {
    let ip = hcloud get-ip $node
    if ($ip | is-empty) {
      error make { msg: $"Cannot resolve IP for ($node). Does the server exist?" }
    }
    ssh wait $ip

    print $"==> Installing NixOS on ($node) \(($ip)\) ..."
    (nix run "github:nix-community/nixos-anywhere" --
      --flake $"($root)#($node)"
      --target-host $"root@($ip)"
      --build-on-remote
      --ssh-option "StrictHostKeyChecking=no"
      --ssh-option "UserKnownHostsFile=/dev/null"
      --copy-host-keys)
  }

  print "==> NixOS installed on all nodes."
  for node in $config.NODES {
    print $"  ($node)  (hcloud get-ip $node)"
  }
  print ""
  print "Next: nu deploy.nu k8s-init"
}

# ---------------------------------------------------------------------------
# k8s-init — bootstrap Kubernetes cluster with kubeadm + Cilium
# ---------------------------------------------------------------------------
def "main k8s-init" [] {
  let ips = $config.NODES | each { |n| hcloud get-ip $n }
  let cp1_ip = $ips.0
  if ($cp1_ip | is-empty) {
    error make { msg: $"Cannot resolve IP for ($config.NODES.0)" }
  }

  # Read version from the flake (single source of truth: common.nix).
  print "==> Reading Kubernetes version from flake ..."
  let version = config k8s-version
  print $"  Kubernetes ($version)"

  # Ensure SSH is up on every node.
  print "==> Waiting for all nodes ..."
  for ip in $ips { ssh wait $ip }

  # Clean slate — idempotent even on a first run.
  print "==> Resetting kubeadm state on all nodes ..."
  for ip in $ips { k8s reset-node $ip }

  # Generate cluster secrets.
  let token    = k8s gen-token
  let cert_key = k8s gen-cert-key

  # Init first control-plane node.
  print $"==> Initialising cluster on ($config.NODES.0) \(($cp1_ip)\) ..."
  k8s init-cluster $cp1_ip $token $cert_key $version

  # Join remaining control-plane nodes.
  for i in 1..2 {
    let node = $config.NODES | get $i
    let ip   = $ips | get $i
    print $"==> Joining ($node) \(($ip)\) ..."
    k8s join-node $ip $cp1_ip $token $cert_key
  }

  # Remove NoSchedule taints so workloads can land on control-plane nodes.
  print "==> Removing control-plane taints ..."
  k8s untaint-all $cp1_ip

  # Deploy Cilium CNI.
  print "==> Installing Cilium CNI ..."
  k8s install-cilium $cp1_ip

  # Final untaint (Cilium may re-add taints during init).
  k8s untaint-all $cp1_ip

  # Fetch kubeconfig.
  print "==> Fetching kubeconfig ..."
  k8s fetch-kubeconfig $cp1_ip

  # Summary.
  print ""
  print "==> Cluster ready!"
  ssh run $cp1_ip "KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide"
  print ""
  print "Usage:"
  print "  export KUBECONFIG=~/.kube/hetzner-k8s.conf"
  print "  kubectl get nodes"
}

# ---------------------------------------------------------------------------
# rebuild — apply NixOS config changes on running servers
# ---------------------------------------------------------------------------
def "main rebuild" [] {
  let root = config flake-root

  for node in $config.NODES {
    let ip = hcloud get-ip $node
    if ($ip | is-empty) {
      error make { msg: $"Cannot resolve IP for ($node). Does the server exist?" }
    }
    ssh wait $ip

    print $"==> Rebuilding ($node) \(($ip)\) ..."
    let target = $"root@($ip)"
    with-env { NIX_SSHOPTS: ($ssh.OPTS | str join " ") } {
      (nixos-rebuild switch
        --flake $"($root)#($node)"
        --target-host $target
        --build-host $target
        --option accept-flake-config true)
    }
  }

  print "==> All nodes rebuilt."
}

# ---------------------------------------------------------------------------
# k8s-upgrade — rolling Kubernetes upgrade
# ---------------------------------------------------------------------------
#
# Workflow:
#   1. Update kubernetes.common.version in modules/kubernetes/common.nix
#   2. Update binary hashes in kubelet.nix and kubeadm.nix
#   3. Run: nu deploy.nu k8s-upgrade
#
# This will:
#   a. Rebuild all nodes (deploys new kubeadm/kubelet/kubectl binaries)
#   b. On cp-1: kubeadm upgrade apply vX.Y.Z
#   c. On cp-2, cp-3: kubeadm upgrade node
#   d. Each node is drained → upgraded → restarted → uncordoned
#
def "main k8s-upgrade" [] {
  let ips = $config.NODES | each { |n| hcloud get-ip $n }
  let cp1_ip = $ips.0
  if ($cp1_ip | is-empty) {
    error make { msg: $"Cannot resolve IP for ($config.NODES.0)" }
  }

  # Read the target version from the flake.
  print "==> Reading target Kubernetes version from flake ..."
  let version = config k8s-version
  print $"  Target: Kubernetes ($version)"

  # Show current cluster version for confirmation.
  print "==> Current cluster state:"
  ssh run $cp1_ip "KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide"
  print ""

  # Step 1: rebuild all nodes (deploy new binaries).
  print "==> Step 1/3: Rebuilding all nodes with new binaries ..."
  main rebuild

  # Step 2: rolling kubeadm upgrade, one node at a time.
  print $"==> Step 2/3: Rolling kubeadm upgrade to ($version) ..."
  for i in 0..2 {
    let node = $config.NODES | get $i
    let ip   = $ips | get $i
    print $"==> Upgrading ($node) \(($ip)\) ..."
    if $i == 0 {
      k8s upgrade-node $ip $node $cp1_ip $version --first
    } else {
      k8s upgrade-node $ip $node $cp1_ip $version
    }
  }

  # Step 3: Upgrade Cilium.
  print $"==> Step 3/3: Upgrading Cilium to ($config.CILIUM_VERSION) ..."
  k8s upgrade-cilium $cp1_ip

  # Refresh kubeconfig (apiserver cert may have been updated).
  print "==> Fetching updated kubeconfig ..."
  k8s fetch-kubeconfig $cp1_ip

  # Summary.
  print ""
  print $"==> Upgrade to ($version) \(Cilium ($config.CILIUM_VERSION)\) complete!"
  ssh run $cp1_ip "KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide"
}

# ---------------------------------------------------------------------------
# destroy — delete all Hetzner Cloud servers
# ---------------------------------------------------------------------------
def "main destroy" [] {
  print "==> Destroying Hetzner Cloud servers ..."
  for node in $config.NODES {
    let exists = try { hcloud server describe $node; true } catch { false }
    if $exists {
      print $"  Deleting ($node) ..."
      hcloud server delete $node
    } else {
      print $"  ($node) does not exist, skipping."
    }
  }
  print "==> All servers destroyed."
}

# ---------------------------------------------------------------------------
# default — print help
# ---------------------------------------------------------------------------
def main [] {
  print "Usage: nu deploy.nu <command>"
  print ""
  print "Commands:"
  print "  create      Create Hetzner Cloud servers and install NixOS"
  print "  install     (Re-)install NixOS on existing servers"
  print "  rebuild     Apply NixOS config changes (no reinstall)"
  print "  k8s-init    Bootstrap Kubernetes cluster with kubeadm + Cilium"
  print "  k8s-upgrade Rolling Kubernetes upgrade (after updating version in Nix)"
  print "  destroy     Delete all Hetzner Cloud servers"
}
