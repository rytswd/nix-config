{ pkgs
, lib
, config
, ...}:

let
  cfg = config.kubernetes.common;
in
{
  options = {
    kubernetes.common.enable = lib.mkEnableOption "Enable common Kubernetes prerequisites.";
    kubernetes.common.version = lib.mkOption {
      type = lib.types.str;
      default = "1.35.1";
      description = "Kubernetes version to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Required kernel modules for Kubernetes networking and load balancing.
    #
    # - br_netfilter: Allows netfilter (both iptables and nftables) to see
    #   bridged traffic. Required for pod-to-pod communication across nodes.
    # - overlay: OverlayFS used by containerd for container image layers.
    # - nf_tables: The nftables backend, used by kube-proxy's nftables mode
    #   which became GA in Kubernetes v1.33. kube-proxy's legacy iptables
    #   mode is superseded, and IPVS mode is deprecated as of v1.35 —
    #   nftables is the recommended mode going forward.
    # - ip_vs*: IPVS (IP Virtual Server) kernel modules. While kube-proxy's
    #   IPVS mode is deprecated since v1.35, these modules are still used
    #   by Cilium and other CNI plugins for service load balancing.
    # - nf_conntrack: Connection tracking, required for NAT and stateful
    #   firewall rules that K8s networking relies on.
    boot.kernelModules = [
      "br_netfilter"
      "overlay"
      "nf_tables"
      "ip_vs"
      "ip_vs_rr"
      "ip_vs_wrr"
      "ip_vs_sh"
      "nf_conntrack"
    ];

    # Sysctl tunables required (or strongly recommended) by kubelet and CNI.
    boot.kernel.sysctl = {
      # Let netfilter see bridged (Layer 2) traffic — without this, pod
      # traffic that crosses a Linux bridge won't hit nftables rules and
      # kube-proxy / CNI policies silently break.
      # NOTE: These sysctls apply regardless of whether the backend is
      # iptables or nftables — both go through the netfilter framework.
      "net.bridge.bridge-nf-call-iptables"  = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;

      # IP forwarding — the node must route packets between pods, services,
      # and the outside world.
      "net.ipv4.ip_forward"          = 1;
      "net.ipv6.conf.all.forwarding" = 1;

      # inotify limits — kubelet, containerd, and various controllers watch
      # many files/dirs. The kernel defaults (8192 watches, 128 instances)
      # are too low and cause "too many open files" under load.
      "fs.inotify.max_user_watches"   = 524288;
      "fs.inotify.max_user_instances" = 8192;

      # Conntrack table size — each active connection (pod↔service,
      # pod↔external) consumes one entry. The default 65536 can be
      # exhausted quickly on a busy node, causing new connections to drop.
      "net.netfilter.nf_conntrack_max" = 131072;
    };

    # Kubernetes v1.34 graduated swap support to GA with two modes:
    # NoSwap (default) and LimitedSwap. We use NoSwap, which means kubelet
    # refuses to start when swap is enabled. Assert explicitly rather than
    # silently overriding it.
    assertions = [{
      assertion = config.swapDevices == [];
      message = "Kubernetes nodes must not have swap enabled. Remove swapDevices from your configuration.";
    }];

    # Ensure cgroup v2 unified hierarchy is used. Kubernetes v1.35 removed
    # cgroup v1 support entirely — kubelet will refuse to start on cgroup v1
    # nodes. NixOS defaults to cgroup v2 on recent kernels, but we make it
    # explicit. The CRI-based cgroup driver auto-detection (GA since v1.34)
    # relies on cgroup v2 to work correctly with containerd.
    boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

    # Minimal set of userspace tools that kubelet, kubeadm preflight checks,
    # and CNI plugins expect to find on PATH.
    #
    # NOTE: We install nftables instead of iptables. Since Kubernetes v1.33,
    # kube-proxy supports an nftables mode (now GA) that fixes long-standing
    # performance problems with the iptables mode.
    environment.systemPackages = with pkgs; [
      nftables        # kube-proxy nftables mode (GA since v1.33)
      iproute2        # ip link/addr/route used by CNI plugins
      ethtool         # kubelet checks NIC features at startup
      socat           # used by kubectl port-forward
      conntrack-tools # conntrack CLI for debugging IPVS/NAT entries
      cri-tools       # crictl CLI to inspect containerd state
    ];
  };
}
