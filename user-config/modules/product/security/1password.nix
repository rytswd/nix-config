{ pkgs, lib, ... }:
# 1Password CLI everywhere (`op`); GUI only on Linux (`_1password-gui`
# isn't packaged for darwin -- install via App Store / Homebrew on macOS).
#
# NOTE: For full desktop-CLI integration on NixOS (biometric unlock, browser
# helper, `op` reading credentials from the running desktop app), the
# system-level `programs._1password{,_gui}.enable` options need to be set
# from a `nixos-config/modules/` module -- this home-manager leaf only
# installs the binaries.
{
  home.packages =
    [ pkgs._1password-cli ]
    ++ lib.optional pkgs.stdenv.isLinux pkgs._1password-gui;
}
