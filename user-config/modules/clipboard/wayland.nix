# Wayland clipboard tools (Linux-only).
#
# The guard keys off `system` rather than `pkgs.stdenv`. `system` is passed
# in from outside (a specialArg), so it's known up front. `pkgs` is instead
# produced by evaluating the modules, so it isn't available yet while the
# import list is still being computed -- reading it here would loop forever.
{
  pkgs,
  lib,
  system,
  ...
}:
lib.throwIf (!lib.hasInfix "linux" system) ''
  user-config/modules/clipboard is Linux-only; import its macos.nix on Darwin.
''
  {
    home.packages = [
      pkgs.wl-clipboard
      pkgs.cliphist
    ];
  }
