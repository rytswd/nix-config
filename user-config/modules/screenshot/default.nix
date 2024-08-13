{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./flameshot.nix
    ./grim.nix
    ./swappy.nix
  ];

  screenshot.flameshot.enable = lib.mkDefault false; # Being explicit, limited wayland support
  screenshot.grim.enable = lib.mkDefault true;
  screenshot.swappy.enable = lib.mkDefault true;
}
