{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    window-manager.niri.enable = lib.mkEnableOption "Enable Niri user settings.";
  };

  config = lib.mkIf config.window-manager.niri.enable {
    # Because the config is quite lengthy, I'm simply mapping a file into the
    # XDG directory.
    xdg.configFile = {
      "niri/config.kdl".source = ./niri-config.kdl;
    };
    home.shellAliases = {
      "nirimvw" = "niri msg action move-window-to-workspace";
    };
  };
}
