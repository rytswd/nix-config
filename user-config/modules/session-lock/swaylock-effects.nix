{ pkgs
, lib
, config
, ...}:

{
  options = {
    session-lock.swaylock-effects.enable = lib.mkEnableOption "Enable swaylock-effects, a fork of swaylock.";
  };

  config = lib.mkIf config.session-lock.swaylock-effects.enable {
    home.packages = [
      pkgs.swaylock-effects
    ];
    xdg.configFile = {
      "swaylock/config".source = ./swaylock/config;
    };
  };
}
