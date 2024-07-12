{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./graphviz.nix
    ./imagemagick.nix
    ./svg.nix
  ];

  image.graphviz.enable = lib.mkDefault true;
  image.imagemagick.enable = lib.mkDefault true;
  image.svg.enable = lib.mkDefault true;
}
