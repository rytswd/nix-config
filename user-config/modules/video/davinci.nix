{ pkgs
, lib
, config
, ...}:

{
  options = {
    video.davinci.enable = lib.mkEnableOption "Enable DaVinci Resolve.";
  };

  config = lib.mkIf config.video.davinci.enable {
    home.packages = [
      pkgs.davinci-resolve
    ];
  };
}
