{ pkgs
, lib
, config
, ...}:

{
  options = {
    notification.standard.enable = lib.mkEnableOption "Enable libnotify and other standard setup.";
  };

  config = lib.mkIf config.notification.standard.enable {
    home.packages = [ pkgs.libnotify ];
  };
}
