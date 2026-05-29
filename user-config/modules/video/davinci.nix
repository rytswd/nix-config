{ pkgs, ... }:
# DaVinci Resolve — not imported by the video bundle's default.nix. Import
# this leaf directly from a host config when I want it.
{
  home.packages = [
    pkgs.davinci-resolve
  ];
}
