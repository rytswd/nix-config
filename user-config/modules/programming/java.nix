{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.java.enable = lib.mkEnableOption "Enable Java development related tools.";
  };

  config = lib.mkIf config.programming.java.enable {
    home.packages = [
      pkgs.jdk
    ];
  };
}
