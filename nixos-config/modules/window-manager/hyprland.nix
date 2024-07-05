{ pkgs
, lib
, config
, ...}:

{
  options = {
    window-manager.hyprland.enable = lib.mkEnableOption "Enable hyprland.";
  };

  config = lib.mkIf config.window-manager.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
