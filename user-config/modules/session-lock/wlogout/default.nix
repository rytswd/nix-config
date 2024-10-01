{ pkgs
, lib
, config
, ...}:

{
  options = {
    session-lock.wlogout.enable = lib.mkEnableOption "Enable wlogout.";
  };

  config = lib.mkIf config.session-lock.wlogout.enable {
    home.packages = [
      pkgs.wlogout
    ];
    xdg.configFile = {
      # I may want to add extra styling at some point.
      # "wlogout/config".source = ./config;
    };
  };
}
