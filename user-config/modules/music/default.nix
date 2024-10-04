{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./util.nix
  ];

  music.util.enable = lib.mkDefault true;
}
