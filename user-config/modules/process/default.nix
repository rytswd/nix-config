{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./pueue.nix
  ];

  process.pueue.enable = lib.mkDefault true;
}
