# Hetzner Cloud Kubernetes Cluster

3-node HA Kubernetes cluster on Hetzner Cloud, provisioned with NixOS.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Hetzner Cloud (nbg1)             │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   cp-1      │  │   cp-2      │  │   cp-3      │  │
│  │  CX33       │  │  CX33       │  │  CX33       │  │
│  │  4 vCPU     │  │  4 vCPU     │  │  4 vCPU     │  │
│  │  8 GB RAM   │  │  8 GB RAM   │  │  8 GB RAM   │  │
│  │  80 GB disk │  │  80 GB disk │  │  80 GB disk │  │
│  │             │  │             │  │             │  │
│  │  etcd       │  │  etcd       │  │  etcd       │  │
│  │  apiserver  │  │  apiserver  │  │  apiserver  │  │
│  │  scheduler  │  │  scheduler  │  │  scheduler  │  │
│  │  ctrl-mgr   │  │  ctrl-mgr   │  │  ctrl-mgr   │  │
│  │  kubelet    │  │  kubelet    │  │  kubelet    │  │
│  │  + workloads│  │  + workloads│  │  + workloads│  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│         │                │                │         │
│         └────── Cilium VXLAN overlay ─────┘         │
└─────────────────────────────────────────────────────┘
```

- **All 3 nodes are control-plane + worker** (untainted) — etcd quorum + workloads on every node
- **Kubernetes v1.35.0** with upstream kubeadm/kubelet/kubectl binaries
- **Cilium** CNI with VXLAN overlay
- **kube-proxy in nftables mode** (GA since v1.33, IPVS deprecated in v1.35)
- **NixOS** with custom modules (not nixpkgs `services.kubernetes`)
- **containerd 2.x** with config version 3 (self-managed, not nixpkgs module)
- **ext4** filesystem (no ZFS overhead — more RAM for pods)
- **Hybrid BIOS + EFI boot** via GRUB (works on all Hetzner VM generations)
- **~€22.47/month** total (3× CX33)

## Prerequisites

- [hcloud CLI](https://github.com/hetznercloud/cli) authenticated
- SSH key added to your Hetzner Cloud project
- SSH agent running with the corresponding private key
- [Nushell](https://www.nushell.sh/) ≥ 0.100

## Quick Start

```bash
cd nixos-config/hetzner-k8s

# 1. Create servers + install NixOS + bootstrap Kubernetes
nu deploy.nu create
nu deploy.nu k8s-init

# 2. Use the cluster
export KUBECONFIG=~/.kube/hetzner-k8s.conf
kubectl get nodes
```

## Commands

| Command                    | Description                                        |
|----------------------------|----------------------------------------------------|
| `nu deploy.nu create`      | Create Hetzner Cloud servers and install NixOS     |
| `nu deploy.nu install`     | (Re-)install NixOS on existing servers             |
| `nu deploy.nu rebuild`     | Apply NixOS config changes (no reinstall)          |
| `nu deploy.nu k8s-init`    | Bootstrap Kubernetes cluster with kubeadm + Cilium |
| `nu deploy.nu k8s-upgrade` | Rolling Kubernetes upgrade                         |
| `nu deploy.nu destroy`     | Delete all Hetzner Cloud servers                   |

## Script Structure

```
deploy.nu          # Main entry point — thin orchestrator
lib/
  config.nu        # Constants: location, server type, K8s version, etc.
  ssh.nu           # SSH helpers for ephemeral servers
  hcloud.nu        # Hetzner Cloud CLI wrappers
  k8s.nu           # kubeadm init/join, Cilium install, token generation
```

## NixOS Modules

Custom Kubernetes modules under `modules/kubernetes/`:

| Module           | Purpose                                                      |
|------------------|--------------------------------------------------------------|
| `common.nix`     | Kernel modules, sysctl, cgroup v2, nftables, system packages |
| `containerd.nix` | containerd 2.x with config v3, SystemdCgroup, CNI path setup |
| `kubelet.nix`    | Upstream kubelet binary + systemd service with kubeadm args  |
| `kubeadm.nix`    | Upstream kubeadm + kubectl binaries                          |
| `networking.nix` | Firewall rules, reverse-path filter (loose), VXLAN ports     |

### NixOS Lessons Learned

Things that differ from a standard kubeadm-on-Ubuntu setup:

- **kubelet needs `mount` on PATH**: NixOS doesn't put `util-linux` in service
  PATH by default. Without it, kubelet can't mount tmpfs volumes for projected
  service account tokens, so **every pod** gets stuck in `ContainerCreating`.
- **CNI bin_dir must include runtime plugins**: Cilium installs `cilium-cni`
  to `/opt/cni/bin` at runtime. containerd's `bin_dir` must point there, with
  nixpkgs CNI plugins symlinked alongside.
- **Reverse-path filter breaks pod networking**: NixOS enables strict rpfilter
  by default. Pod traffic from `10.0.x.x` arriving on Cilium interfaces fails
  the check. Use `checkReversePath = "loose"`.
- **kubelet unit needs all args baked in**: NixOS manages unit files in the nix
  store (read-only), so kubeadm's drop-in mechanism doesn't work. All flags
  (`--config`, `--kubeconfig`, `--bootstrap-kubeconfig`, `$KUBELET_KUBEADM_ARGS`)
  must be in ExecStart directly.
- **`networking.useNetworkd = true` is required**: `systemd.network.enable`
  only creates unit files — it doesn't enable the systemd-networkd service.
  Without `useNetworkd`, the server has no network after reboot.

## Upgrading Kubernetes

The Kubernetes version is defined in one place: `modules/kubernetes/common.nix`
(`kubernetes.common.version`). The deploy scripts read it from the flake at
runtime — there is no duplicated version constant.

```bash
# 1. Update the version in Nix
#    Edit: modules/kubernetes/common.nix  →  default = "1.36.0";

# 2. Update binary hashes (build will fail with correct hashes)
#    Edit: modules/kubernetes/kubelet.nix  →  hash = "sha256-...";
#    Edit: modules/kubernetes/kubeadm.nix  →  hash = "sha256-..."; (×2)

# 3. Rolling upgrade — rebuilds all nodes, then upgrades one at a time
nu deploy.nu k8s-upgrade
```

The `k8s-upgrade` command:
1. Rebuilds all nodes (deploys new kubeadm/kubelet/kubectl binaries)
2. On cp-1: `kubeadm upgrade apply vX.Y.Z`
3. On cp-2, cp-3: `kubeadm upgrade node`
4. Each node is drained → upgraded → kubelet restarted → uncordoned
5. Fetches updated kubeconfig

## Key Decisions

### Why ext4, not ZFS?
ZFS's ARC cache would consume ~1 GB of the 8 GB per node. ext4 is simpler and
leaves that RAM for pods.

### Why upstream binaries, not nixpkgs kubernetes?
Exact version pinning (v1.35.0) and full control over the systemd unit, config,
and kubeadm compatibility. The nixpkgs `services.kubernetes` module makes
assumptions that conflict with a standard kubeadm workflow.

### Why no `--cloud-provider=external`?
Without a Cloud Controller Manager deployed in the cluster, this flag causes
the kubelet to omit the node's InternalIP, which breaks Cilium tunneling and
all pod networking. Since we're not using a CCM, we omit the flag entirely.
