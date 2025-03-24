{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./helix.nix
    ./vscode.nix
    ./zed.nix
  ];

  editor.emacs.enable = lib.mkDefault true;
  editor.neovim.enable = lib.mkDefault true;
  editor.helix.enable = lib.mkDefault true;
  editor.vscode.enable = lib.mkDefault true;
  # TODO: The build failure with the latest flake input, disabling it.
  # editor.zed.enable = lib.mkDefault true;
}
