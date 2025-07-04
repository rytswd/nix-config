{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./age.nix
    ./gpg.nix
    ./sops.nix
  ];

  security.age.enable = lib.mkDefault true;
  security.gpg.enable = lib.mkDefault true;
  security.sops.enable = lib.mkDefault true;
}
