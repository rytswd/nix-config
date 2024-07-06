{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./gtk.nix
  ];

  appearance.gtk.enable = lib.mkDefault true;
}
