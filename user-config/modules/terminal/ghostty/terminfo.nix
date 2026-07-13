# Ghostty terminfo only -- for headless hosts that are ssh'd INTO from a
# Ghostty terminal but never run Ghostty themselves.
#
# Without this, the remote side doesn't know TERM=xterm-ghostty and the
# line editor degrades in confusing ways (duplicated echo like `lss` for
# `ls`, broken backspace, half-working Alt bindings) -- the failure mode
# looks like a shell bug, not a missing terminfo entry. Shipping just the
# terminfo output is tiny; the full Ghostty package stays out of headless
# closures. NixOS already puts the profile's share/terminfo on the search
# path, so installing the package is all that's needed.
#
# Imported by the full ghostty module (terminal bundle) AND directly by
# headless profiles (e.g. user-config/ryota/server.nix) that skip the
# terminal bundle entirely.
#
# The terminfo must come from the SAME source as the Ghostty app (the flake
# input), otherwise buildEnv sees two share/terminfo/g/ghostty entries from
# different versions (e.g. flake 1.3.2-dev vs nixpkgs 1.3.1-terminfo) and
# fails with a "conflicting subpath" error. The flake package exposes a
# dedicated `terminfo` output, so headless closures still stay tiny.
#
# On Darwin the flake has no buildable Ghostty package, so fall back to the
# nixpkgs terminfo -- there the app is never installed via Nix, so nothing
# conflicts with it.
{ pkgs, inputs, ... }:
{
  home.packages = [
    (
      if pkgs.stdenv.isDarwin then
        pkgs.ghostty.terminfo
      else
        inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default.terminfo
    )
  ];
}
