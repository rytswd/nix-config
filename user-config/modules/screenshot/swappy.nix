{ pkgs
, lib
, config
, ...}:

{
  options = {
    screenshot.swappy.enable = lib.mkEnableOption "Enable Swappy.";
  };

  config = lib.mkIf config.screenshot.swappy.enable {
    home.packages = [
      pkgs.swappy
    ];
    xdg.configFile = {
      "swappy/config".text = ''
        [Default]
        save_dir=$HOME/Pictures/Screenshots/
        save_filename_format=ss-%Y%m%d-%H%M%S.png
        show_panel=false
        line_size=5
        text_size=20
        text_font=sans-serif
        paint_mode=brush
        early_exit=false
        fill_shape=false
      '';
    };
  };
}
