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
      # pkgs.brave # Not supported for aarch64-linux

      pkgs.glxinfo # For OpenGL etc.

      pkgs.signal-desktop

      ###------------------------------
      ##   Ghostty
      #--------------------------------
      # Because it's managed in a private repository for now, adding this as a
      # separate entry.
      # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
      # only built in NixOS.
      ghostty.packages.aarch64-linux.default
    ];

    stateVersion = "23.11";
  };

  programs = {
    wofi = {
      enable = true;
      # More config to be placed here.
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
      }

      * {
        ${if config.hostId == "yoga" then ''
          font-size: 18px;
        '' else ''

        ''}
      }
      '';
      settings = [{
        height = 30;
        layer = "top";
        position = "bottom";
        tray = { spacing = 10; };
        modules-center = [ "sway/window" ];
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
        ] ++ (if config.hostId == "yoga" then [ "battery" ] else [ ])
      ++ [
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
        "sway/mode" = { format = ''<span style="italic">{}</span>''; };
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
    };
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
      };
    };
  };
}
