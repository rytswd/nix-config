{ pkgs
, lib
, config
, ...}:

{
  # NOTE: AGS (Aylur's GTK Shell) can provide notification handling. While I
  # could bundle all the AGS modules into a single setup, I'm purposely making
  # each module as a separate entry for now.
  imports = [
    ./standard.nix
    ./dunst.nix
    ./ags-notification.nix
  ];

  notification.standard.enable = lib.mkDefault true;
  notification.dunst.enable = lib.mkDefault false; # Being explicit
  notification.ags-notification.enable = lib.mkDefault false; # Being explicit
}
