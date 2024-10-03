{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    window-manager.yabai.enable = lib.mkEnableOption "Enable yabai user settings.";
  };

  config = lib.mkIf config.window-manager.yabai.enable {
    # Because the config is quite lengthy, I'm simply mapping a file into the
    # XDG directory. All the code is generated with the Org Mode tangle.
    xdg.configFile = {
      "yabai/yabairc".source = ./yabairc;
    };
  };
}
