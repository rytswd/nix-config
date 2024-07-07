{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./swww.nix
  ];

  wallpaper.swww.enable = lib.mkDefault true;
}
