{ pkgs
, lib
, config
, ...}:

{
  options = {
    launcher.rofi.enable = lib.mkEnableOption "Enable Rofi.";
  };

  config = lib.mkIf config.launcher.rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      # Because I use bemoji, I don't really need rofi-emoji plugin.
      # plugins = [
      #   pkgs.rofi-emoji-wayland
      # ];
      extraConfig = {
        show-icons = true;
        modi = "window,drun";
        terminal = "ghostty";
        combi-hide-mode-prefix = true;
      };
      # Because of the CSS like input, it's easier to target a file, and map it
      # with XDG config.
      theme = "custom.rasi";
    };
    xdg.configFile = {
      "rofi/themes/custom.rasi".source = ./rofi-theme.rasi;
    };
  };
}
