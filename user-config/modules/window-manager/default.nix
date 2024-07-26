{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./hyprland
    ./niri
  ];

  window-manager.hyprland.enable = lib.mkDefault true;
  window-manager.niri.enable = lib.mkDefault true;
}
