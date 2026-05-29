{ pkgs, ... }:
{
  home.packages = [ pkgs.terraform ];
  home.shellAliases.tf = "terraform";
}
