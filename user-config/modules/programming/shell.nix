{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.shell.enable = lib.mkEnableOption "Enable Shell development related tools.";
  };

  config = lib.mkIf config.programming.shell.enable {
    home.packages = [
      pkgs.shellcheck
    ];
  };
}
