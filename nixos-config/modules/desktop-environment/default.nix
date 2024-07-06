{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./gnome.nix
  ];

  desktop-environment.gnome.enable = lib.mkDefault true;
}
