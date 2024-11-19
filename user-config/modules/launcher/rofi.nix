{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    launcher.rofi.enable = lib.mkEnableOption "Enable Rofi.";
  };

  config = lib.mkIf config.launcher.rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = [
        pkgs.rofi-emoji
      ];
      extraConfig = {
        show-icons = true;
        modi = "drun,emoji,ssh";
      };
    };
  };

}
