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
      plugins = let
        # Pending PR https://github.com/NixOS/nixpkgs/pull/360018
        obs-advanced-masks = pkgs.callPackage ./obs-advanced-masks.nix {};
      in [
        pkgs.obs-studio-plugins.obs-gradient-source
        pkgs.obs-studio-plugins.obs-composite-blur
        pkgs.obs-studio-plugins.obs-3d-effect
        pkgs.obs-studio-plugins.obs-source-clone
        pkgs.obs-studio-plugins.obs-move-transition

        # Custom
        obs-advanced-masks
      ];
    };
  };
}
