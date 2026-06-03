{
  config,
  pkgs,
  lib,
  self,
  ...
}:

# UTM-hosted aarch64-linux NixOS VM. Most behaviour comes from shared
# bundles (mirroring asus-z13 minus the asus-only leaves); UTM-specific
# bits live in `nixos-config/modules/virtual-machine/utm.nix`.
#
# Things this host intentionally does NOT use, vs asus-z13:
#   - boot/limine.nix     (UTM uses plain systemd-boot via UEFI)
#   - filesystem/zfs.nix  (single-disk ext4, no ZFS)
#   - devices/yubikey.nix (no YubiKey in the guest)
#   - machine-specific/{laptop,asus,asus-webcam}.nix

{
  imports = [
    ###----------------------------------------
    ##  Boot
    #------------------------------------------
    "${self}/nixos-config/modules/boot"
    "${self}/nixos-config/modules/boot/systemd-boot.nix"

    ###----------------------------------------
    ##  Virtual machine
    #------------------------------------------
    # `virtual-machine` bundle = generic QEMU-guest baseline
    # (qemu-guest profile, spice-vdagentd).
    "${self}/nixos-config/modules/virtual-machine"
    # `virtual-machine/utm.nix` adds the UTM-specific overrides
    # (spice-webdavd, systemd-boot consoleMode=0, LIBGL software fallback).
    "${self}/nixos-config/modules/virtual-machine/utm.nix"

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
    # Bundle only -- the yubikey leaf is asus-host-only.
    "${self}/nixos-config/modules/devices"
  ];

  ###========================================
  ##   Other specific configurations
  #==========================================

  ###----------------------------------------
  ##   Other
  #------------------------------------------
  # NOTE: This should match the name used for nixosConfigurations, so that nh
  # tool can automatically find the right target.
  networking.hostName = "nixos-utm";
  networking.useDHCP = lib.mkDefault true;

  # Fresh VM install -- start at current.
  system.stateVersion = "26.05";
}
