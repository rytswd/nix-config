{ pkgs, ... }:
# https://surrealdb.com/ — not imported by the database bundle's default.nix.
# Import this leaf directly from a host config when I want it.
{
  home.packages = [
    pkgs.surrealdb
  ];
}
