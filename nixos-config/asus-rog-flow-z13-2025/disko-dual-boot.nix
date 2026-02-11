{
  # Mount the existing Windows ESP — NOT managed/formatted by disko
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # NOTE: This partition needs to be manually created. This is done so
        # that I can keep the option of Windows dual boot.
        device = "/dev/disk/by-partlabel/nixos";
        content = {
          type = "luks";
          name = "crypted";
          # interactive password entry
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
