{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./japanese.nix
  ];

  i18n.japanese.enable = lib.mkDefault false; # BROKEN NOW
}
