{ pkgs
, lib
, config
, ...}:

{
  options = {
    desktop-environment.cosmic.enable = lib.mkEnableOption "Enable COSMIC.";
  };

  config = lib.mkIf config.desktop-environment.cosmic.enable {
    # services.desktopManager.cosmic.enable = true;
  };
}
