{
  disko.devices = {
    disk = {
      # NixOS ESP - manually created 1GB partition, referenced by label
      # Created BEFORE root partition for conventional ordering
      # Create with: sgdisk -n 7:315529216:+1G -t 7:EF00 -c 7:nixos-esp /dev/nvme0n1
      nixos-esp = {
        type = "disk";
        device = "/dev/disk/by-partlabel/nixos-esp";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };

      # NixOS root - manually created partition, referenced by label
      # After shrinking old partition 7 and creating ESP first
      # Create with: sgdisk -n 8:0:1938903039 -t 8:8300 -c 8:nixos /dev/nvme0n1
      nixos-root = {
        type = "disk";
        device = "/dev/disk/by-partlabel/nixos";
        content = {
          type = "luks";
          name = "crypted";
          settings.allowDiscards = true;
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          acltype = "posixacl";
          xattr = "sa";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          mountpoint = "none";
        };

        datasets = {
          # The container dataset
          "store" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };

          # The ephemeral root
          "store/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
            # Create the blank snapshot immediately after creation
            postCreateHook = "zfs snapshot zroot/store/root@blank";
          };

          # The Nix store (kept separate so it doesn't get wiped)
          "store/nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };

          # The persistence layer which would be used for bind mount
          "store/persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix/persist";
          };

          # Home
          "store/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
            # Snapshot blank if you want ephemeral home too
            postCreateHook = "zfs snapshot zroot/store/home@blank";
          };
        };
      };
    };
  };
}
