{ pkgs, ... }:
# Slack — not imported by the communication bundle's default.nix. Import
# this leaf directly from a host config if you actually want it.
{
  home.packages = [ pkgs.slack ];
}
