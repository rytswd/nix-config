{ pkgs, config, ... }:
{
  programs.firefox.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  home.packages = [
    pkgs.librewolf
  ];
}
