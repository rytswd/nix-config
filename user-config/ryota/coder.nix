# Home Manager profile for Coder workspaces.
#
# A dev-container-friendly subset of the full Ryota HM profile. Compared
# to `nixos.nix` / `macos.nix` this drops anything desktop / windowing /
# media-related and keeps shell + terminal + editor + vcs + dev tooling.
#
# Activated via standalone HM (`nix run .#hm -- switch` from a coder
# workspace, or `home-manager switch --flake .#ryota@coder`). The `hm`
# dispatcher maps `coder-*` / `*-devspace-*` hostnames here.
#
# Username / home directory default to `ryota` / `/home/ryota` but use
# `mkDefault` so the actual workspace user (often `coder` or `root`) can
# override per-workspace without forking the profile.
{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
{
  imports = [
    ###----------------------------------------
    ##  Library helpers
    #------------------------------------------
    "${self}/user-config/modules/lib/paths.nix"

    ###----------------------------------------
    ##  Home Manager itself
    #------------------------------------------
    "${self}/user-config/modules/home-manager"

    ###----------------------------------------
    ##  Core dev environment
    #------------------------------------------
    "${self}/user-config/modules/shell"
    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/editor"
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/security"

    ###----------------------------------------
    ##  Useful in dev containers
    #------------------------------------------
    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/llm"
    "${self}/user-config/modules/product/cloud"
    "${self}/user-config/modules/product/vcs"

    ###----------------------------------------
    ##  Intentionally excluded on coder workspaces
    #------------------------------------------
    # appearance/, window-manager/, wallpaper/, screenshot/,
    # session-lock/, linux-widget/, launcher/, bar/, notification/,
    # clipboard/, music/, video/, image/, i18n/, key-remap/,
    # database/, product/collaboration/, product/music/,
    # product/file-management/, product/security/
    #
    # All Linux-desktop, sync-tool, or auth-store concerns that either
    # don't apply or don't make sense inside a short-lived container.
    # Re-add per-workspace by direct import if needed.
  ];

  ###----------------------------------------
  ##  Identity defaults
  #------------------------------------------
  # mkDefault so the actual workspace can override without forking the
  # profile (e.g., Coder images that run as `coder` or `root`).
  home.username      = lib.mkDefault "ryota";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  # Cross-cycle stability: bump only when consciously migrating.
  home.stateVersion = "25.11";
}
