{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.java.enable = lib.mkEnableOption "Enable Java development related tools.";
  };

  config = lib.mkIf config.programming-language.java.enable {
    home.packages = [
      pkgs.jdk
    ];
  };
}
