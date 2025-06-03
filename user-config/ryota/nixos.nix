# NixOS specific Home Manager configurations

{ config
, pkgs
, system
, inputs
, ... }:

let username = "ryota";
in {
    imports = [
      # The shell setup defines some aliases, and in order to allow overriding,
      # calling this earlier than other modules.
      ../modules/shell
      # The rest of the module call order is rather arbitrary, just in order of
      # importance for my own use case.
      ../modules/key-remap/xremap
      ../modules/appearance
      ../modules/window-manager
      ../modules/launcher
      ../modules/bar
      ../modules/clipboard
      ../modules/notification
      ../modules/process
      ../modules/terminal
      ../modules/vcs
      ../modules/wallpaper
      ../modules/session-lock
      ../modules/browser
      ../modules/editor
      ../modules/programming
      ../modules/vpn
      ../modules/security
      ../modules/kubernetes
      ../modules/service
      ../modules/file-management
      ../modules/dictionary
      ../modules/communication
      ../modules/i18n
      ../modules/image
      ../modules/screenshot
      ../modules/music
      ../modules/video
      ../modules/linux-widget

      # Extra modules based on private setup.
      inputs.nix-config-private.user-modules.email
      # inputs.nix-config-private.user-modules.civo
    ];

    ###----------------------------------------
    ##   Module related options
    #------------------------------------------
    bar.waybar.enable = true;
    bar.ags.enable = true;
    kubernetes.extra.enable = true;
    communication.slack.enable = true;
    communication.signal.enable = true;
    communication.discord.enable = true;
    communication.zoom.enable = true;
    notification.swaync.enable = true;
    service.surrealdb.enable = true;
    window-manager.hyprland.enable = true;
    window-manager.niri.enable = true;

    ###----------------------------------------
    ##   Other Home Manager Setup
    #------------------------------------------
    programs.home-manager.enable = true;
    xdg.enable = true;

    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";

      packages = [
        # Utility
        pkgs.glxinfo # For OpenGL etc.
      ];

      stateVersion = "23.11";
    };
  }
