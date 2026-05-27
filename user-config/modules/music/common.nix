{ pkgs, ... }:
{
  home.packages = [
    pkgs.spotify
  ];

  # MPRIS "last-active player" router used by `playerctl` when a single key
  # (e.g. XF86AudioPlay) should target whatever's playing now. Noctalia,
  # waybar, swaync and AGS all read MPRIS directly and don't need this; only
  # WM keybindings that shell out to `playerctl` benefit. None of the current
  # WM configs bind playerctl, so this is dormant for now — kept to make
  # adding such bindings later a one-line change.
  services.playerctld.enable = true;
}
