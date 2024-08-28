{ pkgs
, lib
, config
, ...}:

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

    ./direnv
    ./starship
    ./atuin
    ./yazi
    ./tmux # I don't use it much, but keeping it in.
  ];

  shell.standard.enable = lib.mkDefault true;
  shell.aliases.enable = lib.mkDefault true;
  shell.env.enable = lib.mkDefault true;
  shell.util.enable = lib.mkDefault true;
  shell.bash.enable = lib.mkDefault true;
  shell.fish.enable = lib.mkDefault true;
  shell.nushell.enable = lib.mkDefault true;
  shell.zsh.enable = lib.mkDefault true;

  shell.direnv.enable = lib.mkDefault true;
  shell.starship.enable = lib.mkDefault true;
  shell.atuin.enable = lib.mkDefault true;
  shell.yazi.enable = lib.mkDefault true;
  shell.tmux.enable = lib.mkDefault false; # Being explicit
}
