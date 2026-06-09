# Karabiner-Elements config (macOS). The app itself is installed as a
# Homebrew cask via macos-config/modules/input/karabiner-elements.nix.
#
# NOTE: this is a read-only store symlink, so changes made in the Karabiner
# GUI won't persist. Edit karabiner.json here instead. Karabiner reads it
# fine read-only; the dual-role Caps Lock mapping works without GUI writes.
{ ... }:
{
  xdg.configFile = {
    "karabiner/karabiner.json".source = ./karabiner.json;
  };
}
