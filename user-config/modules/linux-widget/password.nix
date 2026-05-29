{ pkgs, ... }:
{
  home.packages = [
    # NOTE: Seahorse is "Passwords and Keys" app from GNOME. It used to be a
    # part of pkgs.gnome, but now it's a top-level application from Nix 24.11.
    pkgs.seahorse
  ];
}
