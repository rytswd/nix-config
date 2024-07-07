{ pkgs
, lib
, config
, ...}:

{
  options = {
    clipboard.wayland.enable = lib.mkEnableOption "Enable clipboard for Wayland environment.";
  };

  config = lib.mkIf config.clipboard.wayland.enable {
    home.packages = [
      pkgs.wl-clipboard
      pkgs.cliphist
    ];
  };
}
