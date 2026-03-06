{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./dconf.nix
    ./gtk.nix
  ];

  appearance.dconf.enable = lib.mkDefault true;
  appearance.gtk.enable = lib.mkDefault true;
}
