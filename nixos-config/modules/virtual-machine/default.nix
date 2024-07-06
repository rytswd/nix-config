{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./spice.nix
  ];

  virtual-machine.spice.enable = lib.mkDefault true;
}
