{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.ags.enable = lib.mkEnableOption "Enable AGS (Aylur's GTK Shell).";
  };

  config = lib.mkIf config.bar.ags.enable {
    imports = [ inputs.ags.homeManagerModules.default ];
    programs.ags = {
      enable = true;
      configDir = ./ags;
    };
  };
}
