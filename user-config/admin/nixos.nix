# NixOS specific Home Manager configurations
#
# NOTE: This user is only used for configuring the system setup, and thus only
# limited amount of programs and settings are pulled in.
#

{
  config,
  pkgs,
  system,
  inputs,
  self,
  ...
}:

let
  username = "admin";
in
{
  imports = [
    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    # The rest of the module call order is rather arbitrary, just in order of
    # importance for my own use case.
    "${self}/user-config/modules/shell"
    "${self}/user-config/modules/key-remap/xremap"
    "${self}/user-config/modules/appearance"
    "${self}/user-config/modules/window-manager"
    "${self}/user-config/modules/launcher"
    "${self}/user-config/modules/bar"
    "${self}/user-config/modules/clipboard"
    "${self}/user-config/modules/notification"
    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/wallpaper"
    "${self}/user-config/modules/session-lock"
    "${self}/user-config/modules/browser"
    "${self}/user-config/modules/editor"
    "${self}/user-config/modules/vpn"
    "${self}/user-config/modules/security"
    "${self}/user-config/modules/linux-widget"

    # Add Nix related toolings only
    "${self}/user-config/modules/programming/nix.nix"

    # User specific config
    ./home-git-clone.nix
  ];

  ###----------------------------------------
  ##   Module related options
  #------------------------------------------
  bar.waybar.enable = true;
  editor.helix.enable = false;
  editor.vscode.enable = false;
  notification.swaync.enable = true;

  programming.nix.enable = true;

  ###----------------------------------------
  ##   Other Home Manager Setup
  #------------------------------------------
  programs.home-manager.enable = true;
  xdg.enable = true;

  home = {
    # I specifically use different version for system and home.
    enableNixpkgsReleaseCheck = false;

    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = [
      # Utility
      pkgs.mesa-demos # For OpenGL etc.
    ];

    stateVersion = "24.05";
  };
}
