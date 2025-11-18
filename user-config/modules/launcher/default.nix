{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./anyrun.nix
    ./fuzzel.nix
    ./rofi.nix
    ./walker.nix
    ./wofi.nix
  ];

  launcher.anyrun.enable = lib.mkDefault true;
  launcher.fuzzel.enable = lib.mkDefault true;
  launcher.rofi.enable = lib.mkDefault true;
  launcher.walker.enable = lib.mkDefault true;
  launcher.wofi.enable = lib.mkDefault false; # Being explicit
}
