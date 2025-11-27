{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./awww.nix
    ./mpvpaper.nix
  ];

  wallpaper.awww.enable = lib.mkDefault true;
  wallpaper.mpvpaper.enable = lib.mkDefault false;
}
