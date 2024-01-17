# NixOS specific Home Manager configurations

{ pkgs
, username
, ... }:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "23.11";
}
