{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./yubikey.nix
  ];

  devices.bluetooth.enable = lib.mkDefault true;
  devices.keyboard.enable = lib.mkDefault true;
  devices.yubikey.enable = lib.mkDefault false; # Being explicit
}
