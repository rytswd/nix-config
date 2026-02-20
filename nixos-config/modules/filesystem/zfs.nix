{ pkgs
, lib
, config
, ...}:

{
  options = {
    filesystem.zfs.enable = lib.mkEnableOption "Enable ZFS.";
  };

  config = lib.mkIf config.filesystem.zfs.enable {
    # NOTE: Make sure to adjust the ZFS version according to the kernel,
    # something like below in hardware.nix:
    #
    #     boot.zfs.package = pkgs.zfs_2_4;
    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}
