{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.tools.enable = lib.mkEnableOption "Enable basic tools.";
  };

  config = lib.mkIf config.core.tools.enable {
    environment.systemPackages = [
      pkgs.gnumake
      pkgs.git
      pkgs.cachix
      pkgs.nh
      pkgs.nixos-rebuild-ng
    ];
  };
}
