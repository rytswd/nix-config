{ pkgs, ... }:
# Discord — not imported by the communication bundle's default.nix. Import
# this leaf directly from a host config if you actually want it.
{
  # Instead of using the official Discord app, I'm making use of Vesktop.
  # Discord seems to have less support around Wayland environment.
  home.packages = [ pkgs.vesktop ];
}
