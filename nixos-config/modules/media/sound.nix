{ pkgs
, lib
, config
, ...}:

{
  options = {
    media.sound.enable = lib.mkEnableOption "Enable sound related tools.";
  };

  config = lib.mkIf config.media.sound.enable {
    environment.systemPackages = [
      pkgs.sox
    ];
  };
}
