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
      ../../modules/browser
      ../../modules/vpn
      ../../modules/kubernetes
    ];

    bar.waybar.enable = true;
    kubernetes.extra.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Utility
        pkgs.wl-clipboard
        pkgs.cliphist
        pkgs.glxinfo # For OpenGL etc.
        pkgs.maestral # Dropbox client

        # GUI tools
        pkgs.proton-pass
        pkgs.signal-desktop

        # For WiFi and network manager "nm-applet"
        pkgs.networkmanagerapplet

        pkgs.gnome.seahorse

        ###------------------------------
        ##   Ghostty
        #--------------------------------
        # Because it's managed in a private repository for now, adding this as a
        # separate entry.
        # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
        # only built in NixOS.
        inputs.ghostty.packages.${system}.default
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

    xdg = {
      configFile = {
        "ghostty/config".source = ../../../common-config/ghostty/config-for-nixos;
      };
    };

    # TODO: Fix this up, this is for pin entry for GPG
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  }
