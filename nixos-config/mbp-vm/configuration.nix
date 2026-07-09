{
  config,
  pkgs,
  lib,
  self,
  ...
}:

# Apple Silicon (UTM or Parallels) aarch64-linux NixOS VM. Most behaviour
# comes from shared bundles (mirroring asus-z13 minus the asus-only
# leaves); hypervisor-specific bits live in
# `nixos-config/modules/virtual-machine/{utm,parallels}.nix`, selected by
# the `variant` argument in `./default.nix` (which also sets the
# hostname).
#
# Things this host intentionally does NOT use, vs asus-z13:
#   - boot/limine.nix     (VM uses plain systemd-boot via UEFI)
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
    # (qemu-guest profile, spice-vdagentd). The hypervisor-specific leaf
    # (`virtual-machine/utm.nix` or `virtual-machine/parallels.nix`) is
    # imported by `./default.nix` based on the `variant` argument.
    "${self}/nixos-config/modules/virtual-machine"

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
  # NOTE: `networking.hostName` is set per-variant in `./default.nix`
  # (nixos-utm / nixos-parallels).
  networking.useDHCP = lib.mkDefault true;

  # Fresh VM install -- start at current.
  system.stateVersion = "26.05";
}
