{ pkgs, ... }:
{
  home.packages = [
    pkgs.clipse
  ];
  xdg.configFile = {
    "clipse/config.json".source = ./config.json;
  };
}
