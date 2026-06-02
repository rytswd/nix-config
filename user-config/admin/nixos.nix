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
    # Home-manager bootstrap (CLI install + release-check suppression).
    "${self}/user-config/modules/home-manager"

    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    # The rest of the module call order is rather arbitrary, just in order of
    # importance for my own use case.
    "${self}/user-config/modules/shell"
    "${self}/user-config/modules/key-remap/xremap"
    "${self}/user-config/modules/appearance"
    "${self}/user-config/modules/launcher"
    # Bar leaf — the bar bundle is empty (implementation-agnostic).
    "${self}/user-config/modules/bar/waybar"
    "${self}/user-config/modules/clipboard"
    "${self}/user-config/modules/notification"
    # swaync as the notification daemon (opt-in leaf).
    "${self}/user-config/modules/notification/swaync"
    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/wallpaper"
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

  # Opt out of helix and vscode (default-on once imported, after the
  # mkEnableOption refactor).
  disabledModules = [
    "${self}/user-config/modules/editor/helix.nix"
    "${self}/user-config/modules/editor/vscode.nix"
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };
}
