{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./swww.nix
    ./mpvpaper.nix
  ];

  wallpaper.swww.enable = lib.mkDefault true;
  wallpaper.mpvpaper.enable = lib.mkDefault true;
}
