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

      ../../modules/window-manager
      ../../modules/launcher
      ../../modules/bar
    ];

    bar.waybar.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Browsers
        pkgs.vivaldi
        pkgs.brave # Not supported for aarch64-linux
        # TODO: Add chromium

        # Utility
        pkgs.wl-clipboard
        pkgs.cliphist
        pkgs.glxinfo # For OpenGL etc.
        pkgs.maestral # Dropbox client

        # GUI tools
        pkgs.protonvpn-gui
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

    gtk = {
      enable = true;
      theme = {
        package = pkgs.adw-gtk3;
        name = "Adwaita:dark";
      };
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        # NOTE: This sets the Emacs based key bindings such as C-a to go to the
        # beginning of line.
        gtk-key-theme-name = "Emacs";
      };
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
