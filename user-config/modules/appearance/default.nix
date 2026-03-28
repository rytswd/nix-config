{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./dconf.nix
    ./gtk.nix
    ./noctalia
  ];

  appearance.dconf.enable = lib.mkDefault true;
  appearance.gtk.enable = lib.mkDefault true;
  appearance.noctalia.enable = lib.mkDefault true;
}
