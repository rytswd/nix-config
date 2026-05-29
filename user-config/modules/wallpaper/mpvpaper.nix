{ pkgs, ... }:
# mpvpaper — not imported by the wallpaper bundle's default.nix. Import this
# leaf directly from a host config when I want mpv-based animated wallpapers.
{
  home.packages = [
    pkgs.mpvpaper
  ];
}
