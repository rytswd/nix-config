{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./spice.nix
    ./file-sharing.nix
    ./misc.nix
  ];

  virtual-machine.spice.enable = lib.mkDefault true;
  virtual-machine.file-sharing.enable = lib.mkDefault true;
  virtual-machine.misc.enable = lib.mkDefault true;
}
