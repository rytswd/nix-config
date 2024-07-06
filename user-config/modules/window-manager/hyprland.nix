{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    window-manager.hyprland.enable = lib.mkEnableOption "Enable Hyprland user settings.";
  };

  config = lib.mkIf config.window-manager.hyprland.enable {
    home.packages = [
      inputs.hyprswitch.packages.${system}.default
    ];
  };
}
