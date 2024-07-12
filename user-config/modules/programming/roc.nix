{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.roc.enable = lib.mkEnableOption "Enable Roc development related tools.";
  };

  config = lib.mkIf config.programming.roc.enable {
    home.packages = [
      pkgs.rocpkgs.cli
    ];
  };
}
