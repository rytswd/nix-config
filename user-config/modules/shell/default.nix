{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./util.nix
  ];

  shell.util.enable = lib.mkDefault true;
}
