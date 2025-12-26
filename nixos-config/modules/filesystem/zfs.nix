{ pkgs
, lib
, config
, ...}:

{
  options = {
    filesystem.zfs.enable = lib.mkEnableOption "Enable ZFS.";
  };

  config = lib.mkIf config.filesystem.zfs.enable {
    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}
