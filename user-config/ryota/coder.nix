# Home Manager profile for Coder workspaces.
#
# A lean, SSH-only, headless subset of the full Ryota HM profile. Compared
# to `nixos.nix` / `macos.nix` this drops everything desktop / windowing /
# media / GUI-terminal / GUI-editor related, plus all secret handling that
# needs a key the workspace doesn't have.
#
# Key differences from the desktop profiles, and why:
#   - No `terminal` bundle (ghostty / alacritty are GUI terminal emulators,
#     pointless over SSH). tmux still comes in via the `shell` bundle.
#   - Editors: terminal neovim + helix only. No vscode / zed (GUI) and no
#     emacs (heavy build, opt-in if needed).
#   - git / jj: only the binaries are provided. Their config is managed
#     separately in this env (outside home-manager), so the shared
#     `vcs/git` + `vcs/jj` modules -- which write opinionated config, wire
#     up signing, and pull in the YubiKey module -- are NOT imported.
#   - `local.secrets.enable = false`: no sops decryption key here, so
#     secret-defining modules use their non-secret fallbacks instead of
#     failing at activation.
#
# Activated via standalone HM:
#   - `nix run github:rytswd/nix-config` (the bootstrap app), or
#   - `nix run .#hm -- switch`, or
#   - `home-manager switch --flake .#ryota@coder`.
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
    ##  Shell + multiplexer
    #------------------------------------------
    # Brings in zsh/bash/fish/nushell, starship, atuin (local-only here),
    # direnv, tmux, yazi, etc.
    "${self}/user-config/modules/shell"

    ###----------------------------------------
    ##  Editors (terminal only)
    #------------------------------------------
    "${self}/user-config/modules/editor/neovim"
    "${self}/user-config/modules/editor/helix.nix"

    ###----------------------------------------
    ##  Dev tooling
    #------------------------------------------
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/llm"
    "${self}/user-config/modules/product/cloud"
    "${self}/user-config/modules/product/vcs"

    ###----------------------------------------
    ##  Secret handling (no-op without a key)
    #------------------------------------------
    # sops-nix is still imported so the `sops.*` options exist (modules
    # reference them even when gated off) and `local.secrets.enable` is in
    # scope. With secrets disabled below, no secrets are defined, so
    # activation is a no-op. `sops.nix` just puts the `sops` CLI on PATH.
    "${self}/user-config/modules/security/sops-nix.nix"
    "${self}/user-config/modules/security/sops.nix"

    ###----------------------------------------
    ##  Intentionally excluded on coder workspaces
    #------------------------------------------
    # terminal/ (GUI emulators), editor/{vscode,zed,emacs}, security/{gpg,
    # pass,age,pam-u2f}, the whole vcs/ bundle (git + jj config managed
    # separately here), and all desktop / windowing / media / sync
    # concerns. Re-add per-workspace by direct import if needed.
  ];

  ###----------------------------------------
  ##  Secret handling
  #------------------------------------------
  # SSH-only workspace with no decryption key -- secret-defining modules
  # fall back to non-secret config (see user-config/modules/lib/secrets.nix).
  local.secrets.enable = false;

  ###----------------------------------------
  ##  Identity defaults
  #------------------------------------------
  # mkDefault so the actual workspace can override without forking the
  # profile (e.g., Coder images that run as `coder` or `root`).
  home.username = lib.mkDefault "ryota";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  # Cross-cycle stability: bump only when consciously migrating.
  home.stateVersion = "25.11";
}
