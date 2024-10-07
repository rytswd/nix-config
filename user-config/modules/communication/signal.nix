{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.signal.enable = lib.mkEnableOption "Enable Signal.";
  };

  config = lib.mkIf config.communication.signal.enable {
    home.packages = [ pkgs.signal-desktop ];

    # NOTE:
    # Somehow the default Signal Desktop app don't show up correctly.
    # I can make it work with the following command instead.
    #
    #     ❯ signal-desktop --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --use-tray-icon
    #
    # After that, the app won't start up but it would show up in the tray in
    # Waybar. I can right click the icon and show the app.
    #
    # There seems to be a better way to handle
    # Ref: https://www.reddit.com/r/signal/comments/1c319dz/signaldesktop_starts_minimized_on_wayland/
    #
    # Nix doesn't have the setup for this, so I will need to create an overlay
    # if I want to get this handled.
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/signal-desktop/generic.nix
  };
}
