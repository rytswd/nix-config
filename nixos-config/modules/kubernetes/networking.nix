{ pkgs
, lib
, config
, ...}:

let
  cfg = config.kubernetes.networking;
in
{
  options = {
    kubernetes.networking.enable = lib.mkEnableOption "Enable Kubernetes networking and firewall rules.";
  };

  config = lib.mkIf cfg.enable {
    # Kubernetes control-plane and data-plane ports.
    # All 3 nodes are control-plane + worker, so every node needs all ports.
    #
    # Ref: https://kubernetes.io/docs/reference/networking/ports-and-protocols/
    networking.firewall = {
      enable = true;

      # Cilium uses eBPF and VXLAN tunneling for pod networking. Pod traffic
      # arrives on cilium_host/lxc* interfaces with source IPs from the pod
      # CIDR (10.0.0.0/16). The strict reverse-path filter drops these
      # packets because the kernel's FIB lookup doesn't match the expected
      # ingress interface. Use "loose" mode (rp_filter=2) which only checks
      # that the source is routable via *some* interface, not the specific
      # one the packet arrived on.
      checkReversePath = "loose";

      allowedTCPPorts = [
        # --- Control plane ---
        6443    # kube-apiserver (used by kubectl, kubelet, and all components)
        2379    # etcd client requests
        2380    # etcd peer communication
        10250   # kubelet API (logs, exec, port-forward)
        10259   # kube-scheduler (HTTPS health/metrics)
        10257   # kube-controller-manager (HTTPS health/metrics)

        # --- Worker / data plane ---
        # NodePort range defaults to 30000-32767, opened below.

        # --- Cilium CNI ---
        4240    # Cilium health checks (inter-node)
        4244    # Hubble Relay (observability)
        4245    # Hubble Relay TLS
      ];

      allowedTCPPortRanges = [
        { from = 30000; to = 32767; }  # NodePort services
      ];

      allowedUDPPorts = [
        8472    # Cilium VXLAN overlay (inter-node pod traffic)
        51871   # Cilium WireGuard (transparent encryption, if enabled)
      ];

      # ICMP is needed for Path MTU Discovery and general health checks.
      # NixOS firewall allows ICMP by default when firewall is enabled, but
      # we note it here for documentation.
    };
  };
}
