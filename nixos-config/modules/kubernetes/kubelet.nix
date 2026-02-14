{ pkgs
, lib
, config
, ...}:

let
  cfg = config.kubernetes.kubelet;
  version = config.kubernetes.common.version;

  kubelet = pkgs.stdenv.mkDerivation {
    pname = "kubelet";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubelet";
      hash = "sha256-5zQzEOA/8NQk30OXvfpEaJR9bR8Pk9rFhsHo1uQIbV0=";
    };
    dontUnpack = true;
    installPhase = ''
      install -Dm755 $src $out/bin/kubelet
    '';
  };
in
{
  options = {
    kubernetes.kubelet.enable = lib.mkEnableOption "Enable kubelet service.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ kubelet ];

    # kubelet systemd service compatible with kubeadm.
    #
    # kubeadm expects the kubelet unit to:
    #   1. Pass --config pointing to the KubeletConfiguration YAML that
    #      kubeadm writes to /var/lib/kubelet/config.yaml
    #   2. Pass --kubeconfig pointing to the kubelet client credentials
    #   3. Pass --bootstrap-kubeconfig for initial TLS bootstrap
    #   4. Source /var/lib/kubelet/kubeadm-flags.env for extra flags
    #      (e.g. --cloud-provider=external)
    #
    # NixOS manages the unit file in the nix store, so kubeadm's
    # drop-in mechanism doesn't work. We bake the required arguments
    # directly into ExecStart.
    systemd.services.kubelet = {
      description = "Kubernetes Kubelet";
      documentation = [ "https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/" ];
      after = [ "network-online.target" "containerd.service" ];
      wants = [ "network-online.target" "containerd.service" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        # kubelet shells out to `mount` / `umount` for pod volumes (tmpfs,
        # projected, configMap, secret, etc.) and needs basic system
        # utilities available on $PATH.
        util-linux   # mount, umount
        e2fsprogs    # mkfs.ext4 (local PV formatting)
        iproute2     # ip (network setup)
        iptables     # iptables (kube-proxy / port-forward)
        kmod         # modprobe (needed for some CNIs)
      ];

      serviceConfig = {
        # Source kubeadm-written flags (KUBELET_KUBEADM_ARGS).
        EnvironmentFile = "-/var/lib/kubelet/kubeadm-flags.env";

        ExecStart = lib.concatStringsSep " " [
          "${kubelet}/bin/kubelet"
          "--config=/var/lib/kubelet/config.yaml"
          "--kubeconfig=/etc/kubernetes/kubelet.conf"
          "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf"
          "$KUBELET_KUBEADM_ARGS"
        ];

        Restart = "always";
        RestartSec = "10s";
      };

      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };
  };
}
