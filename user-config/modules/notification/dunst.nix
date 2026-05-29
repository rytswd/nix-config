# dunst — minimal notification daemon. Kept as a reference setup; not imported
# by the bundle's default.nix. Import this leaf directly from a host config
# if you actually want dunst as the notification daemon.
{
  services.dunst.enable = true;
}
