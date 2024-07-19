{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./bluetooth.nix
    ./yubikey.nix
  ];

  devices.bluetooth.enable = lib.mkDefault true;
  devices.yubikey.enable = lib.mkDefault false; # Being explicit
}
