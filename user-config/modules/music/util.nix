{ pkgs
, lib
, config
, ...}:

{
  options = {
    music.util.enable = lib.mkEnableOption "Enable music utilities.";
  };

  config = lib.mkIf config.music.util.enable {
    services.playerctld.enable = true;
  };
}
