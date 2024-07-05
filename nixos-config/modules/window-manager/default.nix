{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./hyprland.nix
    # ./niri.nix
  ];

  window-manager.hyprland.enable = lib.mkDefault true;
  # window-manager.niri.enable = lib.mkDefault true;
}
