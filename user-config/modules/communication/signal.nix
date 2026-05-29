{ pkgs, ... }:
# Signal — not imported by the communication bundle's default.nix. Import
# this leaf directly from a host config if you actually want it.
# NOTE: signal-desktop on Nix does not work on macOS; only import on Linux.
{
  home.packages = [ pkgs.signal-desktop ];
}
