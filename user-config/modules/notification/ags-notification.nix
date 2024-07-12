{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    notification.ags-notification.enable = lib.mkEnableOption "Enable notification handling based on AGS (Aylur's GTK Shell).";
  };

  config = lib.mkIf config.notification.ags-notification.enable {
    home.packages = [
      inputs.ags.packages.${pkgs.system}.default
    ];
    xdg.configFile = {
      "ags-notification".source = ./ags-notification;
      "ags-notification".recursive = true;
    };
  };
}
