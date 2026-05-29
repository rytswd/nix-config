{ pkgs, ... }:
# Chromium — not imported by the browser bundle's default.nix. Import this
# leaf directly from a host config when I want it.
{
  # TODO: Check if this is all I need.
  # TODO: Check puppetteer and other tools
  home.packages = [ pkgs.chromium ];
}
