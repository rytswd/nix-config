{
  config,
  pkgs,
  lib,
  self,
  ...
}:

{
  imports = [
    ###----------------------------------------
    ##  Boot
    #------------------------------------------
    "${self}/nixos-config/modules/boot"
    "${self}/nixos-config/modules/boot/limine.nix"

    ###----------------------------------------
    ##  Filesystem
    #------------------------------------------
    "${self}/nixos-config/modules/filesystem/zfs.nix"

    ###----------------------------------------
    ##  Desktop session
    #------------------------------------------
    "${self}/nixos-config/modules/login-manager/sddm"
    "${self}/nixos-config/modules/window-manager"
    "${self}/nixos-config/modules/desktop-environment"
    "${self}/nixos-config/modules/desktop-environment/dconf.nix"

    ###----------------------------------------
    ##  Cross-host shared bundles
    #------------------------------------------
    "${self}/nixos-config/modules/core"
    "${self}/nixos-config/modules/workstation"
    "${self}/nixos-config/modules/appearance"
    "${self}/nixos-config/modules/media"
    "${self}/nixos-config/modules/security"
    "${self}/nixos-config/modules/vpn"
    "${self}/nixos-config/modules/flatpak"

    ###----------------------------------------
    ##  Devices
    #------------------------------------------
    "${self}/nixos-config/modules/devices"
    "${self}/nixos-config/modules/devices/nvidia.nix"
    "${self}/nixos-config/modules/devices/yubikey.nix"

    ###----------------------------------------
    ##  Machine specific
    #------------------------------------------
    "${self}/nixos-config/modules/machine-specific/laptop.nix"
    "${self}/nixos-config/modules/machine-specific/asus.nix"
  ];

  ###========================================
  ##   Other specific configurations
  #==========================================

  ###----------------------------------------
  ##   YubiKey setup
  #------------------------------------------
  # Re-run the home-manager `yk-git-update.service` for this user when a
  # YubiKey is plugged/unplugged.
  devices.yubikey.user = "ryota";

  ###----------------------------------------
  ##   Other
  #------------------------------------------
  # NOTE: This should match the name used for nixosConfigurations, so that nh
  # tool can automatically find the right target.
  networking.hostName = "asus-rog-zephyrus-g14-2024";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
