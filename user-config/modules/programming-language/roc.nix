{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.roc.enable = lib.mkEnableOption "Enable Roc development related tools.";
  };

  config = lib.mkIf config.programming-language.roc.enable {
    home.packages = [
      pkgs.rocpkgs.cli
    ];
  };
}
