# NixOS specific Home Manager configurations

{ config
, pkgs
, system
, inputs
, ... }:

let username = "ryota";
in {
    imports = [
      ./common.nix
      ./dconf.nix # For GNOME

      ../../modules/appearance
      ../../modules/window-manager
      ../../modules/launcher
      ../../modules/bar
      ../../modules/clipboard
      ../../modules/notification
      ../../modules/terminal
      ../../modules/wallpaper
      ../../modules/browser
      ../../modules/vpn
      ../../modules/kubernetes
      ../../modules/file-management
      ../../modules/communication
    ];

    bar.waybar.enable = true;
    bar.ags.enable = true;
    kubernetes.extra.enable = true;
    communication.slack.enable = true;
    communication.signal.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Utility
        pkgs.glxinfo # For OpenGL etc.

        # GUI tools
        pkgs.proton-pass

        # For WiFi and network manager "nm-applet"
        pkgs.networkmanagerapplet

        # For password management
        pkgs.gnome.seahorse
      ];

      stateVersion = "23.11";
    };

    # TODO: Fix this up, this is for pin entry for GPG
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  }
