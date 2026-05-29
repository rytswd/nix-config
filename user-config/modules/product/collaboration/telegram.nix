{ pkgs, ... }:
{
  home.packages = [
    pkgs.telegram-desktop
    pkgs.tg
  ];
}
