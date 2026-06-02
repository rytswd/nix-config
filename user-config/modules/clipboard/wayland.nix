{ pkgs, ... }:
# Wayland-only -- the bundle's default.nix imports this conditionally on
# `pkgs.stdenv.isLinux`. Don't import this leaf on darwin.
{
  home.packages = [
    pkgs.wl-clipboard
    pkgs.cliphist
  ];
}
