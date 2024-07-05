{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./i18n.nix
  ];

  input.i18n.enable = lib.mkDefault true;
}
