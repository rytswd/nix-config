{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./dunst.nix
    ./wired.nix
  ];

  notification.dunst.enable = lib.mkDefault false; # Being explicit
  notification.wired.enable = lib.mkDefault true;
}
