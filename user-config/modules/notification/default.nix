{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./standard.nix
    ./swaync

    # More for references
    ./dunst.nix
    # NOTE: AGS (Aylur's GTK Shell) can provide notification handling. While I
    # could bundle all the AGS modules into a single setup, I'm purposely making
    # each module as a separate entry for now.
    ./ags-notification.nix
  ];

  notification.standard.enable = lib.mkDefault true;
  notification.swaync.enable = lib.mkDefault false; # Being explicit
  notification.dunst.enable = lib.mkDefault false; # Being explicit
  notification.ags-notification.enable = lib.mkDefault false; # Being explicit
}
