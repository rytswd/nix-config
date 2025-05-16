{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.yaml.enable = lib.mkEnableOption "Enable YAML related tools.";
  };

  config = lib.mkIf config.programming.yaml.enable {
    home.packages = [
      pkgs.dyff
    ];
  };
}
