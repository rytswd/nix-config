{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./font.nix
  ];

  appearance.font.enable = lib.mkDefault true;
}
