{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./fuzzel.nix
    ./wofi.nix
  ];

  # Fuzzel works better with Niri, and thus making it the default.
  launcher.fuzzel.enable = lib.mkDefault true;
  launcher.wofi.enable = lib.mkDefault false; # Being explicit
}
