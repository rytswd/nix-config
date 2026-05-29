{ pkgs, ... }:
# Roc — not imported by the programming bundle's default.nix (build currently
# broken). Import this leaf directly from a host config when I want to try.
{
  home.packages = [
    pkgs.rocpkgs.cli
  ];
}
