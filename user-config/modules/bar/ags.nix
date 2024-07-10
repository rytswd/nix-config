{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.ags.homeManagerModules.default ];
  options = {
    bar.ags.enable = lib.mkEnableOption "Enable AGS (Aylur's GTK Shell).";
  };

  config = lib.mkIf config.bar.ags.enable {
    programs.ags = {
      enable = true;
      configDir = ./ags;
    };
  };
}
