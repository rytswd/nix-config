{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./bluetooth.nix
  ];

  devices.bluetooth.enable = lib.mkDefault true;
}
