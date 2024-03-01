# NixOS specific Home Manager configurations

{ pkgs
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
