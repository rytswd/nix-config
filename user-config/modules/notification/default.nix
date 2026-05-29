{
  # The bundle only pulls in shared notification client tooling (libnotify).
  # The notification *daemon* is host-specific — hosts import one of
  # ./swaync, ./dunst, or ./ags-notification.nix directly.
  imports = [
    ./standard.nix
  ];
}
