# yabai — not imported by the window-manager bundle's default.nix. Import
# this leaf directly from a host config when I want it.
{
  # Because the config is quite lengthy, I'm simply mapping a file into the
  # XDG directory. All the code is generated with the Org Mode tangle.
  xdg.configFile = {
    "yabai/yabairc".source = ./yabairc;
  };
}
