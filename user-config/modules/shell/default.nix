{
  imports = [
    ./standard.nix
    # NOTE: Any alias defined here should be overridable from other modules
    # (though it is unlikely to need to), and thus having this aliases defined
    # earlier.
    ./aliases.nix

    ./env.nix
    ./util.nix
    ./bash.nix
    ./fish.nix
    ./nushell.nix
    ./zsh.nix

    ./swapdir.nix

    ./direnv
    ./starship
    ./atuin
    ./tmux
    ./yazi
  ];
}
