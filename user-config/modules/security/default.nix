{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./gpg.nix
  ];

  security.gpg.enable = lib.mkDefault true;
}
