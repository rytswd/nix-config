{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.virtualisation.docker.enable = lib.mkEnableOption "Enable docker.";
  };

  config = lib.mkIf config.core.virtualisation.docker.enable {
    virtualisation = {
      docker = {
        enable = true;
        # NOTE: When using rootless Docker, I cannot make it work with GPU, such
        # as using it with Ollama.
        # rootless = {
        #   enable = true;
        #   setSocketVariable = true;
        # };
      };
      podman = {
        enable = true;
      };

      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd];
          };
        };
      };
    };
    # Trust local bridge used for VMs
    # Ref: https://www.reddit.com/r/NixOS/comments/18qtsoz/no_internet_in_virtmanagerkvm_guest/
    networking.firewall.trustedInterfaces = [ "virbr0" ];
  };
}
