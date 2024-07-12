{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.keybase.enable = lib.mkEnableOption "Enable Keybase related tooling.";
  };

  config = lib.mkIf config.service.keybase.enable {
    home.packages = [
      pkgs.keybase
    ];
  };
}
