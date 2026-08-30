# rnote -- handwritten note taking / sketching for stylus + touch input.
# https://github.com/flxzt/rnote
#
# Linux-only on purpose. nixpkgs advertises `platforms = unix`, so
# `config.local.availablePackages` would happily keep it on aarch64-darwin,
# where it has no cache coverage and would drag in a full Rust + GTK4 +
# libadwaita source build for an app that's only really used on the tablet.
#
# Gated in `config` via `pkgs.stdenv`, never in `imports` -- `pkgs` is produced
# by evaluating the modules, so reading it while the import list is still being
# computed loops forever.
{ pkgs, lib, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    pkgs.rnote
  ];
}
