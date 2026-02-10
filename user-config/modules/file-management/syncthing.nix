{ pkgs
, lib
, config
, ...}:

{
  options = {
    rytswd.file-management.syncthing.enable = lib.mkEnableOption "Enable Dropbox.";
  };


  config = lib.mkIf config.rytswd.file-management.syncthing.enable {
    services.syncthing = {
      enable = true;
      # group = "users";
      guiAddress = "0.0.0.0:8384";
    };
  };
}
