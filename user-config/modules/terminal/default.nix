{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./ghostty.nix
    ./alacritty.nix
    ./kitty.nix
  ];

  terminal.ghostty.enable = lib.mkDefault true;
  terminal.alacritty.enable = lib.mkDefault true;
  terminal.kitty.enable = lib.mkDefault false; # Being explicit
}
