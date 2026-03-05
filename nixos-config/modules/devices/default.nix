{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./yubikey.nix
    ./librepods.nix
  ];

  devices.bluetooth.enable = lib.mkDefault true;
  devices.keyboard.enable = lib.mkDefault true;
  devices.yubikey.enable = lib.mkDefault false; # Being explicit
  devices.librepods.enable = lib.mkDefault true;
}
