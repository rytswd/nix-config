{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./xremap.nix
  ];

  key-remap.xremap.enable = lib.mkDefault true;
}
