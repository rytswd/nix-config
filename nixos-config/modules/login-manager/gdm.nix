{ pkgs
, lib
, config
, ...}:

{
  options = {
    login-manager.gdm.enable = lib.mkEnableOption "Enable GDM.";
  };

  config = lib.mkIf config.login-manager.gdm.enable {
    services.xserver.displayManager.gdm.enable = true;
  };
}
