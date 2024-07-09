{ pkgs
, lib
, config
, inputs
, ...}:

# Ensure that Flake input is in place.

{
  options = {
    notification.wired.enable = lib.mkEnableOption "Enable Wired Notification.";
  };

  config = lib.mkIf config.notification.wired.enable {
    services.wired = {
      enable = true;
      config = ./wired.ron;
    };
  };
}
