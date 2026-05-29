{ pkgs, ... }:
{
  home.packages = [
    pkgs.swaylock-effects
  ];
  xdg.configFile = {
    "swaylock/config".source = ./swaylock/config;
  };
}
