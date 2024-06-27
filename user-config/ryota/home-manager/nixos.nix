# NixOS specific Home Manager configurations

{ config
, pkgs
, ghostty
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
        pkgs.vivaldi
        pkgs.brave # Not supported for aarch64-linux

        pkgs.glxinfo # For OpenGL etc.

        pkgs.protonvpn-gui
        pkgs.signal-desktop

        # For WiFi and network manager "nm-applet"
        pkgs.networkmanagerapplet
	
        pkgs.gnome.seahorse

        pkgs.wl-clipboard # testing clipboard history

        ###------------------------------
        ##   Ghostty
        #--------------------------------
        # Because it's managed in a private repository for now, adding this as a
        # separate entry.
        # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
        # only built in NixOS.
        ghostty.packages.x86_64-linux.default
      ];

      stateVersion = "23.11";
    };

    services = {
      dunst = {
        enable = true;
      };
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
        };
        style = ''
          window {
            font-size: 14px;
            font-family: "FiraCode Nerd Font";
            background-color: rgba(0.4, 0.4, 0.4, 0.7);
            margin: 30px;
            border-radius: 7px;
          }

          #input {
            margin: 0.5em;
            background-color: rgba(0.7, 0.3, 0.2, 0.8);
	      }

          #entry {
            padding: 0.25em;
          }
          #entry:selected {
            background-color: #bbccdd;
            background: linear-gradient(90deg, #bbffdd, #cca5dd);
          }
          #text:selected {
            color: #333;
          }
          image {
            margin: 0 0.3em;
            padding: 0 0.3em;
          }
        '';
      };
      waybar = {
        enable = true;
        systemd.enable = true;
        # NOTE: All taken from the below for now:
        # https://github.com/georgewhewell/nixos-host/blob/master/home/waybar.nix
        style = ''
          ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}

          window#waybar {
            background: transparent;
            border-bottom: none;
            padding: 10px 10px;
          }
          #language {
            margin: 5px 0;
          }
        '';
        settings = [{
          height = 30;
          layer = "top";
          position = "top";
          tray = { spacing = 10; };
          modules-left = [
            "hyprland/window"
            "hyprland/workspaces"
          ];
          modules-center = [
            "hyprland/submap"
          ];
          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "battery"
	    "hyprland/language"
            "clock"
            "tray"
          ];
          battery = {
            format = "{capacity}% {icon}";
            format-alt = "{time} {icon}";
            format-charging = "{capacity}% ";
            format-icons = [ "" "" "" "" "" ];
            format-plugged = "{capacity}% ";
            states = {
              critical = 15;
              warning = 30;
            };
          };
          clock = {
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          memory = { format = "{}% "; };
          network = {
            interval = 1;
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            format-disconnected = "Disconnected ⚠";
            format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
            format-linked = "{ifname} (No IP) ";
            format-wifi = "{essid} ({signalStrength}%) ";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-icons = {
              car = "";
              default = [ "" "" "" ];
              handsfree = "";
              headphones = "";
              headset = "";
              phone = "";
              portable = "";
            };
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            on-click = "pavucontrol";
          };
          "hyprland/window" = {
            icon = true;
            format = "";
          };
	  "hyprland/submap" = {
	    # format = "✌️ {}";
            max-length = 8;
	  };
          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" ];
          };
        }];
      };
    };

    xdg = {
      configFile = {
        "ghostty/config".source = ../../../common-config/ghostty/config-for-nixos;
        "hypr/hyprland-custom.conf".source = ../../../common-config/hyprland/hyprland-custom.conf;
        "hypr/key-bindings.conf".source = ../../../common-config/hyprland/key-bindings.conf;
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
