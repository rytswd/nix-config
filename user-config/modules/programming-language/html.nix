{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.html.enable = lib.mkEnableOption "Enable HTML development related tools.";
  };

  config = lib.mkIf config.programming-language.html.enable {
    home.packages = [
      pkgs.emmet-language-server
    ];
  };
}
