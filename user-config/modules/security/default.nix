{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./age.nix
    ./gpg.nix
  ];

  security.age.enable = lib.mkDefault true;
  security.gpg.enable = lib.mkDefault true;
}
