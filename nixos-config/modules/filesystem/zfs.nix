# ZFS — not imported by the filesystem bundle's default.nix. Import this leaf
# directly from a host config when the host actually uses ZFS.
#
# NOTE: Make sure to adjust the ZFS version according to the kernel,
# something like below in hardware.nix:
#
#     boot.zfs.package = pkgs.zfs_2_4;
{
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };
}
