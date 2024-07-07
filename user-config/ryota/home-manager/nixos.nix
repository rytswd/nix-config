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
      ../../modules/terminal
      ../../modules/wallpaper
      ../../modules/browser
      ../../modules/vpn
      ../../modules/kubernetes
      ../../modules/file-management
    ];

    bar.waybar.enable = true;
    kubernetes.extra.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Utility
        pkgs.glxinfo # For OpenGL etc.

        # GUI tools
        pkgs.proton-pass
        pkgs.signal-desktop

        # For WiFi and network manager "nm-applet"
        pkgs.networkmanagerapplet

        pkgs.gnome.seahorse # For password management
      ];

      stateVersion = "23.11";
    };

    services = {
      dunst = {
        enable = true;
      };
      # dropbox = {
      #   enable = true;
      # };
    };

    # TODO: Fix this up, this is for pin entry for GPG
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  }
