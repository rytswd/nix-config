# NixOS specific Home Manager configurations
#
# NOTE: This user is only used for configuring the system setup, and thus only
# limited amount of programs and settings are pulled in.
#

{ config
, pkgs
, system
, inputs
, ... }:

let username = "admin";
in {
    imports = [
      # The shell setup defines some aliases, and in order to allow overriding,
      # calling this earlier than other modules.
      # The rest of the module call order is rather arbitrary, just in order of
      # importance for my own use case.
      ../modules/shell
      ../modules/key-remap/xremap
      ../modules/appearance
      ../modules/window-manager
      ../modules/launcher
      ../modules/bar
      ../modules/clipboard
      ../modules/notification
      ../modules/terminal
      ../modules/vcs
      ../modules/wallpaper
      ../modules/session-lock
      ../modules/browser
      ../modules/editor
      ../modules/vpn
      ../modules/security
      ../modules/linux-widget
    ];

    ###----------------------------------------
    ##   Module related options
    #------------------------------------------
    bar.waybar.enable = true;
    editor.helix.enable = false;
    editor.vscode.enable = false;
    notification.ags-notification.enable = true;

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
