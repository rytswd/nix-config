{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./util.nix
    ./spotify.nix
  ];

  music.util.enable = lib.mkDefault true;
  music.spotify.enable = lib.mkDefault true;
}
