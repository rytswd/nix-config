{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./xremap.nix
  ];

  key-remap.xremap.enable = lib.mkDefault true;

  # Ref: https://wiki.archlinux.org/title/Input_remap_utilities
}
