# zroot is striped across 6 io2 EBS volumes (durability tier), each wholly
# owned by ZFS; BIOS-boot + /boot live on a dedicated small gp3 volume.
# Instance-store NVMe is attached as L2ARC at boot by the
# `zpool-l2arc-ensure` systemd unit in configuration.nix -- never by disko,
# because those devices are wiped on stop/start and reappear under fresh
# serials each time.
#
# ---------------------------------------------------------------------------
# The /dev/disk/by-id/... paths below are pinned to specific EBS volumes.
# After (re)provisioning, refresh them from the OpenTofu outputs
# `disko_boot_device` / `disko_ebs_devices` of the infra config that owns
# this box. AWS volume id `vol-0abc...` surfaces as `..._vol0abc...`
# (hyphen dropped).
# ---------------------------------------------------------------------------
let
  zfsDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "zroot";
        };
      };
    };
  };
in
{
  fileSystems."/nix".neededForBoot = true;

  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol096792c1d0d5c737a"; # 8G gp3 root
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # BIOS boot partition; EC2 .metal boots legacy BIOS
            };
            bootfs = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
          };
        };
      };
      ebs1 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol05142f283f103a3be";
      ebs2 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol04c47ae4d6e8698cd";
      ebs3 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol08dccddf479f284b3";
      ebs4 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0081133e669c8e0a8";
      ebs5 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0eb55a9495a68beb1";
      ebs6 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0ba38a65620a9e155";
    };

    zpool.zroot = {
      type = "zpool";
      # No `mode` set: all members become striped top-level vdevs.
      rootFsOptions = {
        acltype = "posixacl";
        atime = "off";
        compression = "zstd";
        mountpoint = "none";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
      };
      options.ashift = "12";
      datasets = {
        root = rec {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = mountpoint;
        };
        home = rec {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = mountpoint;
        };
        nix = rec {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            inherit mountpoint;
            # The store is reproducible by definition; don't pay ~0.6ms EBS
            # round-trips for sqlite fsyncs on every path registration.
            # Unclean-crash worst case: nix-store --verify --repair.
            sync = "disabled";
          };
        };
      };
    };
  };
}
