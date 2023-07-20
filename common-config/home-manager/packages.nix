{ pkgs, ... }:

pkgs.lib.attrValues {
  inherit (pkgs)
    # + Core
    coreutils
    curl
    git # NOTE: This is actually installed at system level.
    tmux
    tree
    watch
    wget

    # + Utilities
    bat
    delta
    exa
    fd
    jq # NOTE: This is actually installed at system level.
    ripgrep
    zoxide
    # rm-improved
    # sd

    # + Other
    # tailscale
    # alacritty
    # slack
    # vscode
  ;
}
