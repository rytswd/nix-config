{ pkgs
, lib
, config
, ...}:

{
  options = {
    notification.dunst.enable = lib.mkEnableOption "Enable dunst.";
  };

  config = lib.mkIf config.notification.dunst.enable {
    services.dunst.enable = true;
  };
}
