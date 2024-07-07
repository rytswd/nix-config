{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./ghostty.nix
    ./alacritty.nix
  ];

  terminal.ghostty.enable = lib.mkDefault true;
  terminal.alacritty.enable = lib.mkDefault true;
}
