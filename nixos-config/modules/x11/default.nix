{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./xserver.nix
  ];

  x11.xserver.enable = lib.mkDefault true;
}
