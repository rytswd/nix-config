{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins =
      let
        # NOTE: I used to have the below custom setup before this PR was merged:
        # https://github.com/NixOS/nixpkgs/pull/391725
        # obs-advanced-masks = pkgs.callPackage ./obs-advanced-masks.nix {};
      in
      [
        pkgs.obs-studio-plugins.obs-gradient-source
        pkgs.obs-studio-plugins.obs-composite-blur
        pkgs.obs-studio-plugins.obs-3d-effect
        pkgs.obs-studio-plugins.obs-source-clone
        pkgs.obs-studio-plugins.obs-move-transition
        pkgs.obs-studio-plugins.obs-advanced-masks

        # Custom
        # obs-advanced-masks
      ];
  };
}
