{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.c.enable = lib.mkEnableOption "Enable C related tools.";
  };

  config = lib.mkIf config.programming.c.enable {
    home.packages = [
      pkgs.clang-tools
    ];
  };
}
