{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.telegram.enable = lib.mkEnableOption "Enable Telegram.";
  };

  config = lib.mkIf config.communication.telegram.enable {
    home.packages = [
      pkgs.telegram-desktop
      pkgs.tg
    ];
  };
}
