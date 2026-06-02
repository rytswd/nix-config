{ pkgs, ... }:
# Nyxt -- not imported by the browser bundle's default.nix (build currently
# fails). Import this leaf directly from a host config when I want to try.
{
  home.packages = [ pkgs.nyxt ];
}
