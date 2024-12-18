{ pkgs
, lib
, config
, ...}:

{
  options = {
    security.clamav.enable = lib.mkEnableOption "Enable ClamAV.";
  };

  config = lib.mkIf config.security.clamav.enable {
    services.clamav = {
      scanner.enable = true;
      daemon.enable = true;
      updater.enable = true;
    };
  };
}
