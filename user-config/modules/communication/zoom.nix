{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.zoom.enable = lib.mkEnableOption "Enable Zoom.";
  };

  config = lib.mkIf config.communication.zoom.enable {
    # Instead of using the official Discord app, I'm making use of Vesktop.
    # Discord seems to have less support around Wayland environment.
    home.packages = [ pkgs.zoom-us ];

    xdg.configFile."zoomus.conf" = {
      text = ''
        [General]
        xwayland=false
        enableWaylandShare=true
      '';
    };
  };
}
