{ pkgs
, lib
, config
, ...}:

{
  options = {
    virtualisation.qemu.enable = lib.mkEnableOption "Enable QEMU.";
  };

  config = lib.mkIf config.virtualisation.qemu.enable {
    home.packages = [
      pkgs.qemu
      pkgs.virt-manager
      pkgs.virt-viewer
    ];
  };
}
