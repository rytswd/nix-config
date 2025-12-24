{ config
, pkgs
, lib
, ... }:

{
  imports = [
    ../modules/core
    ../modules/graphics
    ../modules/media
    ../modules/devices
    ../modules/window-manager
    ../modules/login-manager
    ../modules/desktop-environment
    ../modules/input
    ../modules/vpn
    ../modules/x11
    ../modules/appearance
    ../modules/security
    ../modules/flatpak

    # Some machine specific configurations.
    ../modules/machine-specific/asus.nix
    ../modules/machine-specific/laptop.nix
  ];

  core.boot.systemd-boot.enable = true;

  desktop-environment.gnome.dconf.enable = true;
  devices.yubikey.enable = true;

  # NOTE: This should match the name used for nixosConfigurations, so that nh
  # tool can automatically find the right target.
  networking.hostName = "asus-rog-flow-z13-2025";
  # NOTE: Needed for ZFS. Randomly generated.
  networking.hostId = "3700fa4a";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
