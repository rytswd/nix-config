{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.proton-pass.enable = lib.mkEnableOption "Enable Proton Pass.";
  };

  config = lib.mkIf config.service.proton-pass.enable {
    home.packages = [
      pkgs.proton-pass
    ];
  };
}
