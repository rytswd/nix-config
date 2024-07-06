{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./hyprland.nix
  ];

  window-manager.hyprland.enable = lib.mkDefault true;
}
