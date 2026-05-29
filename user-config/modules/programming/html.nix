{ pkgs, ... }:
{
  home.packages = [
    pkgs.emmet-language-server # needs Node runtime to run
  ];
}
