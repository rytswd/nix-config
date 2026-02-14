# Disko configuration for Hetzner Cloud CX-line VMs.
# Hybrid BIOS + EFI boot (compatible with both firmware types).
# Based on the nixos-anywhere example for Hetzner Cloud.
{ lib, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition — GRUB embeds its stage 2 here for
            # legacy BIOS boot on GPT disks.
            bios = {
              size = "1M";
              type = "EF02";
            };
            # EFI System Partition — for UEFI boot. Mounted at /boot
            # so GRUB can install its EFI binary here.
            esp = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "defaults" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
