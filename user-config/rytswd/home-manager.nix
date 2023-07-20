{ config, pkgs, ... }:

let
  username = "rytswd";
  # packages = import ../common-config/home-manager/packages.nix;
  # inherit (pkgs) stdenv;
in
{
  home.username = "${username}";
  # home.homeDirectory = "/Users/${username}";

  # xdg.enable = true;

  home.stateVersion = "22.11";
  # home.packages = packages { inherit pkgs; };
  home.packages = with pkgs;
    [
      git
      exa
    ];

  home.shellAliases = {
    l = "exa -l";
    ls = "exa";
    ll = "exa -lT";
    la = "exa -la";
    llt = "exa -laTF --git --group-directories-first --git-ignore --ignore-glob .git";
  };
}
