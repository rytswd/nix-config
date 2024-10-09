{ pkgs
, lib
, config
, ...}:

{
  options = {
    video.wf-recorder.enable = lib.mkEnableOption "Enable wf-recorder.";
  };

  config = lib.mkIf config.video.wf-recorder.enable {
    home.packages = [ pkgs.wf-recorder ];
  };
}
