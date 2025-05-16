{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.toml.enable = lib.mkEnableOption "Enable TOML related tools.";
  };

  config = lib.mkIf config.programming.toml.enable {
    home.packages = [
      pkgs.taplo
    ];
  };
}
