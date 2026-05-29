{ pkgs, ... }:
# Roc — not imported by the programming bundle's default.nix (build currently
# broken). Import this leaf directly from a host config if you want to try.
{
  home.packages = [
    pkgs.rocpkgs.cli
  ];
}
