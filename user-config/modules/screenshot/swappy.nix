{ pkgs, ... }:
# Swappy -- https://github.com/jtheoof/swappy. Screenshot annotator, typically
# fed from `grim -g "$(slurp)" - | swappy -f -`.
{
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
}
