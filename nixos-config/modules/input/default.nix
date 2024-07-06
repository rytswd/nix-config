{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./i18n.nix
    ./trackpad.nix
  ];

  input.i18n.enable = lib.mkDefault true;
  input.trackpad.enable = lib.mkDefault true;
}
