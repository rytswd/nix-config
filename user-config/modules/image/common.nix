{ pkgs, ... }:
{
  home.packages = [
    pkgs.graphviz     # Graphs / diagrams from textual description. https://graphviz.org/
    pkgs.imagemagick  # General-purpose raster image manipulation. https://github.com/imagemagick/imagemagick
    pkgs.librsvg      # SVG rendering / rasterisation library + CLI. https://wiki.gnome.org/Projects/LibRsvg
  ];
}
