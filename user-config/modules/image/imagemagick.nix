{ pkgs
, lib
, config
, ...}:

{
  options = {
    image.imagemagick.enable = lib.mkEnableOption "Enable ImageMagick.";
  };

  config = lib.mkIf config.image.imagemagick.enable {
    home.packages = [
      pkgs.imagemagick  # https://github.com/imagemagick/imagemagick
    ];
  };
}
