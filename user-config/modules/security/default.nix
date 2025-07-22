{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./age.nix
    ./gpg.nix
    ./sops.nix

    # NOTE: Importing below would enable regardless.
    ./sops-nix.nix
  ];

  security.age.enable = lib.mkDefault true;
  security.gpg.enable = lib.mkDefault true;
  security.sops.enable = lib.mkDefault true;
  security.sops-nix.enable = lib.mkDefault true;
}
