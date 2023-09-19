{ pkgs, ... }:

pkgs.lib.attrValues {
  inherit (pkgs)
    ###------------------------------
    ##   Core Packages
    #--------------------------------
    coreutils
    curl
    git # NOTE: This is actually installed at system level.
    tmux
    tree
    watch
    wget

    ###------------------------------
    ##   Utilities
    #--------------------------------
    bat
    delta
    eza
    fd
    jq # NOTE: This is actually installed at system level.
    ripgrep
    zoxide
    # rm-improved
    # sd

    ###------------------------------
    ##   Other
    #--------------------------------
    # I used to use most of the below, but starting to move away from them.
    # I currently don't see anything to be installed at this level.

    # tailscale
    # alacritty
    # slack
    # vscode
  ;
}
