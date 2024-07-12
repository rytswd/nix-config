# NixOS specific Home Manager configurations

{ config
, pkgs
, system
, inputs
, ... }:

let username = "ryota";
in {
    imports = [
      # The shell setup defines some aliases, and in order to allow overriding,
      # calling this earlier than other modules.
      ../../modules/shell
      ../../modules/appearance
      ../../modules/window-manager
      ../../modules/launcher
      ../../modules/bar
      ../../modules/clipboard
      ../../modules/notification
      ../../modules/terminal
      ../../modules/vcs
      ../../modules/wallpaper
      ../../modules/browser
      ../../modules/editor
      ../../modules/programming
      ../../modules/vpn
      ../../modules/kubernetes
      ../../modules/service
      ../../modules/file-management
      ../../modules/dictionary
      ../../modules/communication
      ../../modules/image
      ../../modules/linux-widget
    ];

    ###----------------------------------------
    ##   Module related options
    #------------------------------------------
    bar.waybar.enable = true;
    bar.ags.enable = true;
    kubernetes.extra.enable = true;
    communication.slack.enable = true;
    communication.signal.enable = true;
    notification.ags-notification.enable = true;

    ###----------------------------------------
    ##   Other Home Manager Setup
    #------------------------------------------
    programs.home-manager.enable = true;
    xdg.enable = true;

    # TODO: Move this somewhere.
    programs.gpg.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Utility
        pkgs.glxinfo # For OpenGL etc.
      ];

      stateVersion = "23.11";
    };

    # TODO: Fix this up, this is for pin entry for GPG
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  }
