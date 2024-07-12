{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.ags.homeManagerModules.default ];
  options = {
    bar.ags.enable = lib.mkEnableOption "Enable notification handling based on AGS (Aylur's GTK Shell).";
  };

  config = lib.mkIf config.bar.ags.enable {
    home.packages = {
      inputs.ags.packages.${pkgs.system}.default;
    };
    xdg.configFile = {
      "ags/notification".source = ./ags-notification;
      "ags/notification".recursive = true;
    };
  };
}
