{ pkgs, ... }:
# bemoji — emoji picker driven by a dmenu-compatible launcher.
{
  home.packages = [
    pkgs.bemoji
    pkgs.wtype # Necessary for ensuring bemoji input can be typed in.
  ];
  home.sessionVariables = {
    BEMOJI_PICKER_CMD = "rofi -dmenu -no-show-icons";
  };
}
