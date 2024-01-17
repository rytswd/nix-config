{ pkgs, ... }:

pkgs.lib.attrValues {
  inherit (pkgs)
    ###------------------------------
    ##   Core Packages
    #--------------------------------
    coreutils
    curl
    git # NOTE: This is also installed at system level.
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
    jq # NOTE: This is also installed at system level.
    ripgrep
    zoxide
    # rm-improved
    # sd
  ;
}
