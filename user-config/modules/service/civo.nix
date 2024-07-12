{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.civo.enable = lib.mkEnableOption "Enable Civo related tooling.";
  };

  config = lib.mkIf config.service.civo.enable {
    home.packages = [
      pkgs.civo
    ];
  };
}
