{ pkgs
, lib
, config
, ...}:

{
  options = {
    linux-widget.bemoji.enable = lib.mkEnableOption "Enable bemoji, emoji picker.";
  };

  config = lib.mkIf config.linux-widget.bemoji.enable {
    home.packages = [
      pkgs.bemoji
      pkgs.wtype # Necessary for ensuring bemoji input can be typed in.
    ];
    home.sessionVariables = {
      BEMOJI_PICKER_CMD = "rofi -dmenu -no-show-icons";
    };
  };
}
