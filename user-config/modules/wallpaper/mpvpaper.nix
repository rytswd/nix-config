{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    wallpaper.mpvpaper.enable = lib.mkEnableOption "Enable mpvpaper.";
  };

  config = lib.mkIf config.wallpaper.mpvpaper.enable {
    home.packages = [
      pkgs.mpvpaper
    ];
  };
}
