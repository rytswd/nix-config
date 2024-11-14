{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./age.nix
    ./gpg.nix
    # NOTE: Not using sops for now.
    ./sops.nix # NOTE: Importing this would enable regardless.
  ];

  security.age.enable = lib.mkDefault true;
  security.gpg.enable = lib.mkDefault true;
}
