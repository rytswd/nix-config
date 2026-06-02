{ pkgs, ... }:
{
  home.packages = [
    pkgs.grim     # Wayland screenshot grabber. https://sr.ht/~emersion/grim/
    pkgs.slurp    # Region selector -- typically piped into grim. https://github.com/emersion/slurp
  ];
}
