{ pkgs
, lib
, config
, ...}:

{
  options = {
    video.obs.enable = lib.mkEnableOption "Enable OBS.";
  };

  config = lib.mkIf config.video.obs.enable {
    programs.obs-studio = {
      enable = true;
      plugins = [
        pkgs.obs-studio-plugins.obs-gradient-source
        pkgs.obs-studio-plugins.obs-composite-blur
        pkgs.obs-studio-plugins.obs-3d-effect
        pkgs.obs-studio-plugins.obs-source-clone
        pkgs.obs-studio-plugins.obs-move-transition

        # Add OBS advanced mask?
      ];
    };
  };
}
