{ config
, pkgs
, lib
, ... }:

{
  imports = [
    ../modules/core
    ../modules/filesystem
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

  core.boot.limine.enable = true;
  # Dual-boot workaround: Limine's efibootmgr detection breaks with ZFS root
  # + separate Windows ESP. Skip efibootmgr and install to UEFI fallback path.
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  system.activationScripts.limine-dual-boot = let
    efibootmgr = "${pkgs.efibootmgr}/bin/efibootmgr";
  in lib.stringAfter [ "etc" ] ''
    ESP="/boot"
    SRC="$ESP/EFI/limine/BOOTX64.EFI"

    # Copy to UEFI fallback path as backup
    if [ -f "$SRC" ]; then
      mkdir -p "$ESP/EFI/BOOT"
      cp -f "$SRC" "$ESP/EFI/BOOT/BOOTX64.EFI"
    fi

    # Register Limine boot entry with correct ESP disk/partition
    # (only if EFI vars are accessible and entry doesn't already exist)
    if [ -d /sys/firmware/efi/efivars ]; then
      if ! ${efibootmgr} | grep -q "Limine"; then
        ${efibootmgr} -c -d /dev/nvme0n1 -p 1 \
          -l '\efi\limine\BOOTX64.EFI' -L 'Limine' || true
      fi
    fi
  '';

  # Secure Boot
  environment.systemPackages = [ pkgs.sbctl ];
  # NOTE: This needs to be set to false upon the initial setup.
  # boot.loader.limine.secureBoot.enable = true;

  filesystem.zfs.enable = true;

  desktop-environment.gnome.dconf.enable = true;
  devices.yubikey.enable = true;

  # Flow Z13 does not have NVidia GPU.
  graphics.nvidia-offload.enable = false;

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
