{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.css.enable = lib.mkEnableOption "Enable CSS development related tools.";
  };

  config = lib.mkIf config.programming.css.enable {
    home.packages = [
      pkgs.dart-sass
    ];
  };
}
