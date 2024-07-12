{ pkgs
, lib
, config
, ...}:

{
  # NOTE: AGS (Aylur's GTK Shell) can provide notification handling. While I
  # could bundle all the AGS modules into a single setup, I'm purposely making
  # each module as a separate entry for now.
  imports = [
    ./dunst.nix
    ./wired.nix
    ./ags-notification.nix
  ];

  notification.dunst.enable = lib.mkDefault false; # Being explicit
  notification.wired.enable = lib.mkDefault false; # Being explicit
  notification.ags-notification.enable = lib.mkDefault false; # Being explicit
}
