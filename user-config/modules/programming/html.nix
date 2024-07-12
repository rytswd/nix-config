{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.html.enable = lib.mkEnableOption "Enable HTML development related tools.";
  };

  config = lib.mkIf config.programming.html.enable {
    home.packages = [
      pkgs.emmet-language-server
    ];
  };
}
