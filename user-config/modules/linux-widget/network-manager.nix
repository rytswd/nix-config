{ pkgs
, lib
, config
, ...}:

{
  options = {
    linux-widget.network-manager.enable = lib.mkEnableOption "Enable Network Manager Applet.";
  };

  config = lib.mkIf config.linux-widget.network-manager.enable {
    home.packages = [
      pkgs.networkmanagerapplet
    ];
  };
}
