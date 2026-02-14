{ pkgs
, lib
, config
, ...}:

let
  cfg = config.kubernetes.containerd;

  # Generate the containerd config as TOML.
  # containerd 2.x uses config version 3 with new plugin namespaces.
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "containerd.toml" {
    version = 3;
    plugins."io.containerd.cri.v1.images".pinned_images = {
      sandbox = "registry.k8s.io/pause:3.10";
    };
    plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc = {
      runtime_type = "io.containerd.runc.v2";
    };
    plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc.options = {
      SystemdCgroup = true;
    };
    plugins."io.containerd.cri.v1.runtime".cni = {
      # Use /opt/cni/bin so that third-party CNI plugins (e.g. Cilium)
      # that install binaries at runtime are found alongside the base
      # plugins we symlink in from nixpkgs.
      bin_dir = "/opt/cni/bin";
    };
  };

  # Validate the config at build time.
  configChecked = pkgs.runCommand "containerd-config-checked.toml" {
    nativeBuildInputs = [ pkgs.containerd ];
  } ''
    containerd -c ${configFile} config dump >/dev/null
    ln -s ${configFile} $out
  '';
in
{
  options = {
    kubernetes.containerd.enable = lib.mkEnableOption "Enable containerd for Kubernetes CRI.";
  };

  config = lib.mkIf cfg.enable {
    # Do NOT use virtualisation.containerd — the nixpkgs module still
    # targets containerd 1.x (config version 2, old plugin paths).
    # We define the service and config ourselves for containerd 2.x.

    environment.systemPackages = with pkgs; [
      containerd
      runc
      cni-plugins
    ];

    # Write the validated config to a well-known path.
    environment.etc."containerd/config.toml".source = configChecked;

    # Populate /opt/cni/bin with the standard CNI plugins from nixpkgs.
    # Third-party CNI plugins (Cilium, Calico, etc.) install additional
    # binaries into /opt/cni/bin at runtime.
    systemd.tmpfiles.rules = [
      "d /opt/cni/bin 0755 root root -"
    ];
    systemd.services.cni-plugins-link = {
      description = "Symlink CNI plugins into /opt/cni/bin";
      wantedBy = [ "multi-user.target" ];
      before = [ "containerd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "link-cni-plugins" ''
          for f in ${pkgs.cni-plugins}/bin/*; do
            bn=$(basename "$f")
            # Don't overwrite third-party plugins (e.g. cilium-cni)
            [ -e "/opt/cni/bin/$bn" ] || ln -sf "$f" "/opt/cni/bin/$bn"
          done
        '';
      };
    };

    systemd.services.containerd = {
      description = "containerd - container runtime";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "local-fs.target"
      ];
      path = with pkgs; [
        containerd
        runc
      ];
      serviceConfig = {
        ExecStart = "${pkgs.containerd}/bin/containerd --config /etc/containerd/config.toml";
        Delegate = "yes";
        KillMode = "process";
        Type = "notify";
        Restart = "always";
        RestartSec = "10";

        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        OOMScoreAdjust = "-999";

        StateDirectory = "containerd";
        RuntimeDirectory = "containerd";
        RuntimeDirectoryPreserve = "yes";
      };
      unitConfig = {
        StartLimitBurst = "16";
        StartLimitIntervalSec = "120s";
      };
    };
  };
}
