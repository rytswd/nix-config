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
    # Shared machine-local values (`local.repoPath`, `local.availablePackages`).
    "${self}/user-config/modules/lib/paths.nix"
    "${self}/user-config/modules/lib/pkgs.nix"
    # Home-manager bootstrap (CLI install + release-check suppression).
    "${self}/user-config/modules/home-manager"

    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    "${self}/user-config/modules/shell"

    # The rest of the module call order is rather arbitrary, just in order of
    # importance for my own use case.
    "${self}/user-config/modules/key-remap/xremap"
    "${self}/user-config/modules/window-manager/niri"
    "${self}/user-config/modules/window-manager/hyprland" # Backup, not really used

    "${self}/user-config/modules/appearance"
    "${self}/user-config/modules/launcher"
    "${self}/user-config/modules/clipboard"
    "${self}/user-config/modules/notification"
    "${self}/user-config/modules/process"
    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/browser"
    "${self}/user-config/modules/editor"
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/vpn"
    "${self}/user-config/modules/security"
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

    "${self}/user-config/modules/database/surrealdb.nix"
    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/kubernetes/kubernetes-extra.nix"

    # Vendor solutions
    "${self}/user-config/modules/product/cloud"
    "${self}/user-config/modules/product/security"
    "${self}/user-config/modules/product/vcs"
    "${self}/user-config/modules/product/collaboration"

    # Extra modules based on private setup.
    inputs.nix-config-private.homeManagerModules.sops-nix
    inputs.nix-config-private.homeManagerModules.email
    inputs.nix-config-private.homeManagerModules.git

    # User specific config
    ./home-git-clone.nix
    ./default-apps.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";
  };
}
