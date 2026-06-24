# zroot is striped across 6 io2 EBS volumes (durability tier), each wholly
# owned by ZFS; BIOS-boot + /boot live on a dedicated small gp3 volume.
# Instance-store NVMe is attached as L2ARC at boot by the
# `zpool-l2arc-ensure` systemd unit in configuration.nix -- never by disko,
# because those devices are wiped on stop/start and reappear under fresh
# serials each time.
#
# ---------------------------------------------------------------------------
# !! The /dev/disk/by-id/... paths below are PLACEHOLDERS. !!
# Fill them in after `aws ec2 run-instances` + `aws ec2 create-volume` /
# `attach-volume`, then on the target host:
#
#     ls -l /dev/disk/by-id/ | grep Amazon_Elastic_Block_Store
#
# and replace each `vol0xxxxxxxxxxxxxxxx` accordingly. See README.org.
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
        device = "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx"; # TODO: 4G gp3 boot vol
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
      # TODO: replace each volume id after attaching the io2 volumes.
      ebs1 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
      ebs2 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
      ebs3 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
      ebs4 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
      ebs5 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
      ebs6 = zfsDisk "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol0xxxxxxxxxxxxxxxx";
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
