{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.shell.enable = lib.mkEnableOption "Enable Shell development related tools.";
  };

  config = lib.mkIf config.programming-language.shell.enable {
    home.packages = [
      pkgs.shellcheck
    ];
  };
}
