{ pkgs, ... }:
{
  programs.firefox.enable = true;
  home.packages = [
    pkgs.librewolf
  ];
}
