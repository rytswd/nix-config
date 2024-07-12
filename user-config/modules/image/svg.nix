{ pkgs
, lib
, config
, ...}:

{
  options = {
    image.svg.enable = lib.mkEnableOption "Enable SVG related tools.";
  };

  config = lib.mkIf config.image.svg.enable {
    home.packages = [
      pkgs.librsvg  # https://wiki.gnome.org/Projects/LibRsvg
    ];
  };
}
