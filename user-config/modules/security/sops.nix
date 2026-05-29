{ pkgs, ... }:
# NOTE: SOPS setup here does not use SOPS Nix, check sops-nix.nix instead.
{
  home.packages = [
    pkgs.sops
  ];
}
