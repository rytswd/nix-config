{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./standard.nix
    ./util.nix
    ./bash.nix
    ./fish.nix
    ./nushell.nix
    ./zsh.nix

    # I don't use it much, but keeping it in.
    ./tmux.nix
  ];

  shell.standard.enable = lib.mkDefault true;
  shell.util.enable = lib.mkDefault true;
  shell.bash.enable = lib.mkDefault true;
  shell.fish.enable = lib.mkDefault true;
  shell.nushell.enable = lib.mkDefault true;
  shell.zsh.enable = lib.mkDefault true;

  shell.tmux.enable = lib.mkDefault false; # Being explicit
