# NixOS specific Home Manager configurations

{
  config,
  pkgs,
  system,
  inputs,
  self,
  ...
}:

let
  username = "ryota";
in
{
  imports = [
    # Shared machine-local values (e.g. `local.repoPath`).
    "${self}/user-config/modules/lib/paths.nix"

    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    "${self}/user-config/modules/shell"
    # The rest of the module call order is rather arbitrary, just in order of
    # importance for my own use case.
    "${self}/user-config/modules/key-remap/xremap"
    "${self}/user-config/modules/appearance"
    "${self}/user-config/modules/window-manager"
    "${self}/user-config/modules/launcher"
    "${self}/user-config/modules/bar"
    "${self}/user-config/modules/clipboard"
    "${self}/user-config/modules/notification"
    "${self}/user-config/modules/process"
    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/wallpaper"
    # ../modules/session-lock # Commenting out as Noctalia handles this.
    "${self}/user-config/modules/browser"
    "${self}/user-config/modules/editor"
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/vpn"
    "${self}/user-config/modules/security"
    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/service"
    "${self}/user-config/modules/file-management"
    "${self}/user-config/modules/dictionary"
    "${self}/user-config/modules/communication"
    "${self}/user-config/modules/i18n"
    "${self}/user-config/modules/image"
    "${self}/user-config/modules/screenshot"
    "${self}/user-config/modules/music"
    "${self}/user-config/modules/video"
    "${self}/user-config/modules/linux-widget"
    "${self}/user-config/modules/llm"
    "${self}/user-config/modules/virtualisation"

    # Extra modules based on private setup.
    inputs.nix-config-private.homeManagerModules.sops-nix
    inputs.nix-config-private.homeManagerModules.email
    inputs.nix-config-private.homeManagerModules.git

    # User specific config
    ./home-git-clone.nix
    ./default-apps.nix
  ];

  ###----------------------------------------
  ##   Module related options
  #------------------------------------------
  # bar.waybar.enable = true;
  kubernetes.extra.enable = true;
  communication.slack.enable = true;
  communication.signal.enable = true;
  communication.discord.enable = true;
  communication.telegram.enable = true;
  communication.zoom.enable = true;
  # notification.swaync.enable = true;
  service.surrealdb.enable = true;
  window-manager.hyprland.enable = true;
  window-manager.niri.enable = true;

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

    stateVersion = "23.11";
  };
}
