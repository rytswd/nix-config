{ pkgs
, lib
, config
, ...}:

{
  options = {
    launcher.wofi.enable = lib.mkEnableOption "Enable Wofi.";
  };

  config = lib.mkIf config.launcher.wofi.enable {
    programs.wofi = {
      enable = true;
      # More config to be placed here.
      settings = {
        gtk_dark = true;
        insensitive = true;
        allow_images = true;
        image_size = 12;
        key_expand = "Tab";
      };
      style = (builtins.readFile ./wofi-styles.css);
    };
  };
}
