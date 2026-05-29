{
  imports = [
    ./emacs.nix
    ./neovim
    ./helix.nix
    ./vscode.nix
    # NOTE: ./zed.nix is intentionally NOT imported here — build is broken
    # with the current flake input. Import the leaf directly if you want it.
  ];
}
