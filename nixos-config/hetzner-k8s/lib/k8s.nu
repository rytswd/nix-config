# Kubernetes cluster bootstrap and upgrade helpers.

use ssh.nu
use config.nu

# ---------------------------------------------------------------------------
# Token / key generation
# ---------------------------------------------------------------------------

# Generate a kubeadm bootstrap token (format: [a-z0-9]{6}.[a-z0-9]{16}).
export def gen-token [] {
  let a = (open /dev/urandom | take 3 | encode hex | str downcase)
  let b = (open /dev/urandom | take 8 | encode hex | str downcase)
  $"($a).($b)"
}

# Generate a 32-byte hex certificate encryption key for --upload-certs.
export def gen-cert-key [] {
  open /dev/urandom | take 32 | encode hex | str downcase
}

# ---------------------------------------------------------------------------
# Node lifecycle
# ---------------------------------------------------------------------------

# Reset kubeadm state on a node (idempotent — safe on a clean node).
export def reset-node [ip: string] {
  print $"  Resetting kubeadm on ($ip) ..."
  ssh run $ip "
    kubeadm reset -f 2>/dev/null || true
    systemctl stop kubelet 2>/dev/null || true
    crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock rm -fa  2>/dev/null || true
    crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock rmp -fa 2>/dev/null || true
    rm -rf /etc/kubernetes/* /var/lib/etcd /var/lib/kubelet/config.yaml /var/lib/kubelet/pki
    mkdir -p /etc/kubernetes/manifests /etc/kubernetes/pki
    systemctl start kubelet 2>/dev/null || true
  "
}

# ---------------------------------------------------------------------------
# Cluster init / join
# ---------------------------------------------------------------------------

# Render kubeadm InitConfiguration + ClusterConfiguration YAML.
export def init-config [cp1_ip: string, token: string, cert_key: string, version: string] {
  $"apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
bootstrapTokens:
  - token: \"($token)\"
    ttl: \"1h\"
    usages:
      - signing
      - authentication
localAPIEndpoint:
  advertiseAddress: \"($cp1_ip)\"
  bindPort: 6443
certificateKey: \"($cert_key)\"
nodeRegistration: {}
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: \"($version)\"
controlPlaneEndpoint: \"($cp1_ip):6443\"
networking:
  podSubnet: \"($config.POD_SUBNET)\"
  serviceSubnet: \"($config.SERVICE_SUBNET)\"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: \"nftables\""
}

# Run kubeadm init on the first control-plane node.
export def init-cluster [ip: string, token: string, cert_key: string, version: string] {
  let cfg = init-config $ip $token $cert_key $version
  ssh run $ip $"
    set -euo pipefail
    cat > /etc/kubernetes/kubeadm-init.yaml <<'KUBEADM_EOF'
($cfg)
KUBEADM_EOF
    kubeadm init --config /etc/kubernetes/kubeadm-init.yaml --upload-certs
  "
}

# Join a node to an existing cluster as a control-plane member.
export def join-node [ip: string, cp1_ip: string, token: string, cert_key: string] {
  ssh run $ip ([
    "set -euo pipefail;"
    $"kubeadm join ($cp1_ip):6443"
    $"--token ($token)"
    "--discovery-token-unsafe-skip-ca-verification"
    "--control-plane"
    $"--certificate-key ($cert_key)"
  ] | str join " ")
}

# Remove the control-plane NoSchedule taint from all nodes.
export def untaint-all [cp1_ip: string] {
  ssh run $cp1_ip "
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true
  "
}

# ---------------------------------------------------------------------------
# Cilium
# ---------------------------------------------------------------------------

# Ensure the Cilium CLI binary is installed on the node.
export def ensure-cilium-cli [cp1_ip: string] {
  ssh run $cp1_ip '
    set -euo pipefail
    mkdir -p /usr/local/bin

    if ! [ -x /usr/local/bin/cilium ]; then
      CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
      curl -sL --remote-name-all \
        "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz{,.sha256sum}"
      sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
      tar xzf cilium-linux-amd64.tar.gz -C /usr/local/bin
      rm -f cilium-linux-amd64.tar.gz{,.sha256sum}
    fi
  '
}

# Install the Cilium CLI and deploy Cilium CNI.
export def install-cilium [cp1_ip: string] {
  ensure-cilium-cli $cp1_ip
  let ver = $config.CILIUM_VERSION
  ssh run $cp1_ip $"
    set -euo pipefail
    export KUBECONFIG=/etc/kubernetes/admin.conf
    /usr/local/bin/cilium install --version ($ver) --set kubeProxyReplacement=true
    /usr/local/bin/cilium status --wait --wait-duration 5m
  "

}

# Upgrade Cilium to the version specified in config.
export def upgrade-cilium [cp1_ip: string] {
  ensure-cilium-cli $cp1_ip
  let ver = $config.CILIUM_VERSION
  print $"  Upgrading Cilium to ($ver) ..."
  ssh run $cp1_ip $"
    set -euo pipefail
    export KUBECONFIG=/etc/kubernetes/admin.conf
    /usr/local/bin/cilium upgrade --version ($ver)
    /usr/local/bin/cilium status --wait --wait-duration 5m
  "
}

# ---------------------------------------------------------------------------
# Kubeconfig
# ---------------------------------------------------------------------------

# Fetch admin.conf to the local machine.
export def fetch-kubeconfig [cp1_ip: string] {
  let dest = $"($env.HOME)/.kube/hetzner-k8s.conf"
  mkdir ($dest | path dirname)
  scp ...$ssh.OPTS $"root@($cp1_ip):/etc/kubernetes/admin.conf" $dest
  print $"  Kubeconfig saved to ($dest)"
}

# ---------------------------------------------------------------------------
# Upgrade
# ---------------------------------------------------------------------------

# Upgrade a single node.  Handles the first node (kubeadm upgrade apply)
# differently from subsequent nodes (kubeadm upgrade node).
export def upgrade-node [
  ip: string
  node_name: string
  cp1_ip: string
  version: string
  --first   # true for the first control-plane node
] {
  let kc = "export KUBECONFIG=/etc/kubernetes/admin.conf"

  # 1. Drain (evict workloads)
  print $"  Draining ($node_name) ..."
  ssh run $cp1_ip $"($kc); kubectl drain ($node_name) --ignore-daemonsets --delete-emptydir-data --timeout=120s"

  # 2. kubeadm upgrade
  if $first {
    print $"  Running kubeadm upgrade apply ($version) on ($node_name) ..."
    ssh run $ip $"kubeadm upgrade apply ($version) -y"
  } else {
    print $"  Running kubeadm upgrade node on ($node_name) ..."
    ssh run $ip "kubeadm upgrade node"
  }

  # 3. Restart kubelet to pick up new KubeletConfiguration
  print $"  Restarting kubelet on ($node_name) ..."
  ssh run $ip "systemctl restart kubelet"

  # 4. Wait for node to become Ready
  print $"  Waiting for ($node_name) to become Ready ..."
  ssh run $cp1_ip $"($kc); kubectl wait --for=condition=Ready node/($node_name) --timeout=120s"

  # 5. Uncordon
  print $"  Uncordoning ($node_name) ..."
  ssh run $cp1_ip $"($kc); kubectl uncordon ($node_name)"
}
