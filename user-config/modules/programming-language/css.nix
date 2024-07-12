{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.css.enable = lib.mkEnableOption "Enable CSS development related tools.";
  };

  config = lib.mkIf config.programming-language.css.enable {
    home.packages = [
      pkgs.dart-sass
    ];
  };
}
