{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./hyprland
    ./niri
    ./yabai
  ];

  window-manager.hyprland.enable = lib.mkDefault false; # Being explicit
  window-manager.niri.enable = lib.mkDefault false; # Being explicit
  window-manager.yabai.enable = lib.mkDefault false; # Being explicit
}
