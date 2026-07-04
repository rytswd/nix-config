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
{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty.terminfo ];
}
