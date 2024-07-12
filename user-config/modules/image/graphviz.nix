{ pkgs
, lib
, config
, ...}:

{
  options = {
    image.graphviz.enable = lib.mkEnableOption "Enable Graphviz.";
  };

  config = lib.mkIf config.image.graphviz.enable {
    home.packages = [
      pkgs.graphviz # https://graphviz.org/
    ];
  };
}
