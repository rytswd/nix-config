{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./gnome.nix
    ./dconf.nix
    ./cosmic.nix
  ];

  desktop-environment.gnome.enable = lib.mkDefault true;
  desktop-environment.gnome.dconf.enable = lib.mkDefault false; # Being explicit
  desktop-environment.cosmic.enable = lib.mkDefault true;
}
