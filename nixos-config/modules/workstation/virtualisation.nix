{ pkgs, ... }:
# Docker + podman + libvirtd. Not imported by the core bundle's default.nix
# on headless hosts (hetzner-k8s uses `disabledModules` to opt out).
{
  virtualisation = {
      docker = {
        enable = true;
        # docker_28 was flagged insecure/unmaintained on 2025-11 (nixpkgs
        # marks it as such), and the module default still resolves to it.
        # Pin docker_29 explicitly until the module default catches up.
        package = pkgs.docker_29;
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
          # NOTE: The below is deprecated as of Oct 2025.
          # ovmf = {
          #   enable = true;
          #   packages = [(pkgs.OVMF.override {
          #     secureBoot = true;
          #     tpmSupport = true;
          #   }).fd];
          # };
        };
      };
    };
  # Trust local bridge used for VMs
  # Ref: https://www.reddit.com/r/NixOS/comments/18qtsoz/no_internet_in_virtmanagerkvm_guest/
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
