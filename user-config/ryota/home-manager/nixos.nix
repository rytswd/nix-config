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
    ];

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
      wofi = {
        enable = true;
        # More config to be placed here.
        settings = {
          gtk_dark = true;
          insensitive = true;
          allow_images = true;
          image_size = 12;
          key_expand = "Tab";
        };
        style = (builtins.readFile ../../../common-config/wofi/styles.css);
      };
      waybar = {
        enable = true;
        systemd.enable = true;
        # NOTE: All taken from the below for now:
        # https://github.com/georgewhewell/nixos-host/blob/master/home/waybar.nix
        style = ''
          ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}
        '' + (builtins.readFile ../../../common-config/waybar/style.css);
        settings = [{
          height = 30;
          layer = "top";
          position = "top";
          spacing = "10";
          tray = { spacing = 10; };
          modules-left = [
            "custom/padd"
            "hyprland/workspaces"
            "custom/padd"
          ];
          modules-center = [
            "custom/padd"
            "hyprland/window"
            "custom/padd"
          ];
          modules-right = [
            "custom/padd"
            "pulseaudio"
            "network"
            "cpu"
            "temperature"
            "battery"
            "hyprland/language"
            "clock"
            "tray"
            "custom/padd"
          ];
          battery = {
            format = "{icon}";
            format-alt = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            format-plugged = "{capacity}% ";
            states = {
              critical = 15;
              warning = 30;
            };
          };
          clock = {
            format = "{:%Y-%m-%d %H:%M}";
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          cpu = {
            format = "";
            format-alt = " {usage}%";
            tooltip = false;
          };
          network = {
            interval = 1;
            format-alt = " {essid} ({signalStrength}%): {ifname} {ipaddr}/{cidr}";
            format-disconnected = "⚠";
            format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
            format-linked = "{ifname} (No IP) ";
            format-wifi = "";
            tooltip-format = "{ipaddr}/{cidr} {bandwidthUpBits} / {bandwidthDownBits}";
          };
          pulseaudio = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{icon} {volume}% {format_source}";
            format-bluetooth-muted = "{icon} 󰖁 {format_source}";
            format-icons = {
              car = "󰄋";
              default = [ "󰕿" "󰖀" "󰕾" ];
              handsfree = "";
              headphones = "󰋋";
              headset = "󰋎";
              phone = "󰏲";
              portable = "󰏲";
            };
            format-muted = "󰖁 {format_source}";
            format-source = "󰍬 {volume}%";
            format-source-muted = "󰍭";
            on-click = "pavucontrol";
          };
          temperature = {
            critical-threshold = 80;
            format = "{icon}";
            format-alt = "{icon} {temperatureC}°C";
            format-icons = [ "" ];
          };
          "hyprland/language" = {
            format-en = "🇺🇸";
            format-en-dvorak = "󰌓";
            format-ja = "🇯🇵";
          };
          "hyprland/window" = {
            icon = true;
            # format = "";
          };
          "hyprland/workspaces" = {
            all-outputs = true;
            format = "{icon}: {windows}";
            window-rewrite-default = "󰈔";
            window-rewrite = {
              "(.*)Emacs" = " ";
              "(.*)Ghostty" = " ";
              "(.*)Vivaldi" = " ";
            };
            # format-icons = "active";
          };
          "custom/padd" = {
            format = "  ";
            interval = "once";
            tooltip = false;
          };

        }];
      };
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
