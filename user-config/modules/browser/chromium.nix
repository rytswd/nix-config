{ pkgs, ... }:
# Chromium — not imported by the browser bundle's default.nix. Import this
# leaf directly from a host config if you actually want it.
{
  # TODO: Check if this is all I need.
  # TODO: Check puppetteer and other tools
  home.packages = [ pkgs.chromium ];
}
