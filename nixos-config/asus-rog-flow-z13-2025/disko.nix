{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
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
