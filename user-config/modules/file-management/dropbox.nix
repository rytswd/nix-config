{ pkgs
, lib
, config
, ...}:

{
  options = {
    file-management.dropbox.enable = lib.mkEnableOption "Enable Dropbox.";
  };

  config = lib.mkIf config.file-management.dropbox.enable {
    home.packages =
      if pkgs.stdenv.isDarwin
      then []
      # NOTE: I couldn't make Dropbox to work in Linux env. For now, Maestral
      # does what I need.
      else [ pkgs.maestral ]
    ;

    # TODO: Configure systemd to start maestral daemon.
  };
}
