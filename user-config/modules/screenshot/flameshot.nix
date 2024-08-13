{ pkgs
, lib
, config
, ...}:

{
  options = {
    screenshot.flameshot.enable = lib.mkEnableOption "Enable Flameshot.";
  };

  config = lib.mkIf config.screenshot.flameshot.enable {
    services.flameshot = {
      enable = true;
      # Ref: https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
      settings = {
        General = {
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
        };
      };
    };
  };
}
