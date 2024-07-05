{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./setup.nix
  ];

  flatpak.enable = lib.mkDefault true;
}
