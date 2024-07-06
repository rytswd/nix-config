# NixOS specific Home Manager configurations

{ config
, pkgs
, system
, ghostty
, hyprland-plugins
, hyprswitch
, ... }:

let username = "ryota";
in {
    imports = [
      ./common.nix
      ./dconf.nix # For GNOME

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
        ghostty.packages.${system}.default

        hyprswitch.packages.${system}.default
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

    programs = {

    };

    xdg = {
      configFile = {
        "ghostty/config".source = ../../../common-config/ghostty/config-for-nixos;
        "hypr/".source = ../../../common-config/hyprland;
        "hypr/".recursive = true;
      };
    };

    # TODO: Fix this up, this is for pin entry for GPG
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    wayland = {
      windowManager = {
        hyprland = {
          enable = true;
          # This assumes that the above XDG config is mapped to provide extra conf
          # file, which can refer to as a relative path.
          extraConfig = ''
            source=./hyprland-custom.conf
          '';
          # TODO: Add extra handling so that extra files can be added based on
          # the machine requirements (Asus will need specific resolution
          # handling, whereas UTM won't need it.)
        };
      };
    };
  }
