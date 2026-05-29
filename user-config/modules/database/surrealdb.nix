{ pkgs, ... }:
# https://surrealdb.com/ — not imported by the service bundle's default.nix.
# Import this leaf directly from a host config if you actually want it.
{
  home.packages = [
    pkgs.surrealdb
  ];
}
