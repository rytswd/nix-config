# This file content is mainly generated by `nixos-generate-config` with NixOS
# installer:
#
#     /etc/nixos/configuration.nix
#     /etc/nixos/hardware-configuration.nix
#
# While most of the configurations are kept as generated, there are some parts
# that have been added, removed, or modified.
#
# Other configurations for this machine can be found in other files.

{ config
, lib
, pkgs
, modulesPath
, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # By default, NixOS uses 'by-uuid', but label is more convenient.
  fileSystems."/" =
    { device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/SYSTEM";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];
  # Make use of zram compressed block device in RAM.
  zramSwap.enable = true;

  networking.useDHCP = lib.mkDefault true;
}
