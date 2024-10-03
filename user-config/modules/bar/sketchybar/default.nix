{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.sketchybar.enable = lib.mkEnableOption "Enable Sketchybar.";
  };

  config = lib.mkIf config.bar.sketchybar.enable {
    xdg.configFile = {
      "sketchybar".source = ./config;
      "sketchybar".recursive = true;
    };
  };
}
