# Wayland clipboard tools (Linux-only).
#
# Gated in `config` via `pkgs.stdenv`, never in `imports`: `pkgs` is produced
# by evaluating the modules, so reading it while the import list is still
# being computed loops forever. `system` can't stand in for it either -- it's
# a specialArg only in the standalone home-manager setup, not when
# home-manager runs as a NixOS module.
{ pkgs, lib, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    pkgs.wl-clipboard
    pkgs.cliphist
  ];
  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "user-config/modules/clipboard is Linux-only; import its macos.nix on Darwin.";
    }
  ];
}
