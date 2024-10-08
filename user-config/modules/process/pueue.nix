{ pkgs
, lib
, config
, ...}:

{
  options = {
    process.pueue.enable = lib.mkEnableOption "Enable Pueue.";
  };

  config = lib.mkIf config.process.pueue.enable {
    services.pueue = {
      enable = true;
    };
  };
}
