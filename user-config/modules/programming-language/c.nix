{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.c.enable = lib.mkEnableOption "Enable C related tools.";
  };

  config = lib.mkIf config.programming-language.c.enable {
    home.packages = [
      pkgs.clang-tools
    ];
  };
}
