{ pkgs
, lib
, config
, ...}:

{
  options = {
    # Ref: https://github.com/jtheoof/swappy
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
        show_panel=true
        line_size=5
        text_size=20
        text_font=sans-serif
        paint_mode=rectangle
        early_exit=false
        fill_shape=false
      '';
    };
  };
}
