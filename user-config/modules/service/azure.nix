{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.azure.enable = lib.mkEnableOption "Enable Azure related tooling.";
  };

  config = lib.mkIf config.service.azure.enable {
    home.packages = [
      pkgs.azure-cli
    ];
  };
}
