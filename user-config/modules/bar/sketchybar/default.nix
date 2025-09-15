{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.sketchybar.enable = lib.mkEnableOption "Enable Sketchybar.";
  };

  config = lib.mkIf config.bar.sketchybar.enable {
    # NOTE: I'm probably not going to maintain this, as the default bar can
    # achieve most of the aesthetic updates I wanted following the macOS
    # Tahoe upgrade.
    xdg.configFile = {
      "sketchybar".source = ./config;
      "sketchybar".recursive = true;
    };
  };
}
