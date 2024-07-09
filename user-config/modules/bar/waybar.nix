{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.waybar.enable = lib.mkEnableOption "Enable Waybar.";
  };

  config = lib.mkIf config.bar.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      # NOTE: A lot of config taken from the below for now:
      # https://github.com/georgewhewell/nixos-host/blob/master/home/waybar.nix
      style = ''
          ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}
      '' + (builtins.readFile ./waybar-style.css);
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
          "custom/shortcuts"
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
          format = " {icon} ";
          format-alt = " {icon}  {capacity}%";
          format-charging = " 󰂄  {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-plugged = " 󰂄  {capacity}%";
          states = {
            critical = 10;
            warning = 20;
          };
        };
        clock = {
          interval = 1;
          format = "{:%Y-%m-%d %H:%M:%S}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
        };
        cpu = {
          format = "  ";
          format-alt = "   {usage}%";
          tooltip = false;
        };
        network = {
          interval = 1;
          format-alt = "   {essid} ({signalStrength}%): {ifname} {ipaddr}/{cidr}";
          format-disconnected = "⚠";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
          format-linked = "{ifname} (No IP) ";
          format-wifi = "  ";
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
          format = " {icon} ";
          format-alt = "{icon} {temperatureC}°C";
          format-icons = [ "" ];
        };
        "hyprland/language" = {
          format-en = " 🇺🇸 ";
          format-en-dvorak = " 󰌓 ";
          format-ja = " 🇯🇵 ";
        };
        "hyprland/window" = {
          icon = true;
          format = "";
        };
        "hyprland/workspaces" = {
          all-outputs = true;
          format = "{icon}: {windows}";
          window-rewrite-default = "󰈔";
          window-rewrite = {
            "(.*)Emacs" = " ";
            "(.*)Ghostty" = " ";
            "(.*)Vivaldi" = " ";
            "(.*)Brave" = " ";
            "(.*)Slack" = " ";
            "(.*)Signal" = "󰍩 ";
          };
          # format-icons = "active";
        };
        "custom/shortcuts" = {
          format = "";
          on-click = "fuzzel";
        };
        "custom/padd" = {
          format = "  ";
          interval = "once";
          tooltip = false;
        };
      }];
    };
  };
}
