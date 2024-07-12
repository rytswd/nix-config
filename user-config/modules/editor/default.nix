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
  ];

  editor.emacs.enable = lib.mkDefault true;
  editor.neovim.enable = lib.mkDefault true;
  editor.helix.enable = lib.mkDefault true;
  editor.vscode.enable = lib.mkDefault true;
}
