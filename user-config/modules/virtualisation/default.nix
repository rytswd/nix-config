{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./qemu.nix
  ];

  virtualisation.qemu.enable = lib.mkDefault true;
}
