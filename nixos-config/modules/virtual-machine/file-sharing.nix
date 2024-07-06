{ pkgs
, lib
, config
, ...}:

{
  options = {
    virtual-machine.file-sharing.enable = lib.mkEnableOption "Enable file sharing between guest and host machines.";
  };

  config = lib.mkIf config.virtual-machine.file-sharing.enable {
    # WebDav for sharing the host's directory in UTM guest machine.
    # Ref: https://docs.getutm.app/guest-support/linux/#spice-webdav
    services.spice-webdavd.enable = true;

    # In order to mount the volume, I'd need something like below. This didn't
    # quite work, and should be specific to host/guest setup, and thus kept
    # commented out.

    # # Ref: https://www.reddit.com/r/NixOS/comments/b5p6f7/how_do_i_use_davfs2/
    # services.davfs2.enable = true;
    # services.autofs = {
    #   enable = true;
    #   # Clear code inspired by:
    #   # https://github.com/GaetanLepage/dotfiles/blob/7855d6e3f082cbdb1a20142a8299cb33729366ab/nixos/tuxedo/autofs.nix#L16
    #   autoMaster = let mapConf = pkgs.writeText "autofs.mnt" ''
    #     mbp-coding \
    #         -fstype=davfs,uid=1000,file_mode=666,dir_mode=777,rw \
    #         :http\://localhost\:9843/Coding
    #     mbp-documents \
    #         -fstype=davfs,uid=1000,file_mode=666,dir_mode=777,rw \
    #         :http\://localhost\:9843/Documents
    #     '';
    #   in ''
    #     /utm-host   ${mapConf}  --timeout 600
    #   '';
    # };
  };
}
