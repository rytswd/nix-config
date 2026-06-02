# Sketchybar -- not imported by the bar bundle's default.nix. Import this leaf
# directly from a host config when I want it.
#
# NOTE: I'm probably not going to maintain this, as the default bar can
# achieve most of the aesthetic updates I wanted following the macOS
# Tahoe upgrade.
{
  xdg.configFile = {
    "sketchybar".source = ./config;
    "sketchybar".recursive = true;
  };
}
