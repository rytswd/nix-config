# A lot of configurations have been taken / inspired by:
# https://github.com/mitchellh/nixos-config/blob/main/machines/vm-shared.nix

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

    # NOTE: This may be an overkill to have a module, but using this approach
    # just for the uniformity.
    # Commenting this out for now as asusctl isn't working correctly.
    ../modules/machine-specific/asus.nix
  ];

  desktop-environment.gnome.dconf.enable = true;
  devices.yubikey.enable = true;

  # NOTE: This should match the name used for nixosConfigurations, so that nh
  # tool can automatically find the right target.
  networking.hostName = "asus-rog-zephyrus-g14-2024";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
