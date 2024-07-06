{ pkgs
, lib
, config
, ...}:

{
  options = {
    x11.xserver.enable = lib.mkEnableOption "Enable xserver.";
  };

  config = lib.mkIf config.x11.xserver.enable {
    services.xserver = {
      enable = true;
      exportConfiguration = true;

      # System wide configuration, which would be overridden by user specified
      # configuration. This is useful for Login Manager to have extra layouts.
      # In order to persist with the relevant keyboard layouts, separate
      # home-manager setup needs to be in place.
      xkb = {
        layout = "us,us,jp";
        variant = "dvorak,,";
        options = "ctrl:nocaps"; # Configure Caps Lock to be ctrl.
      };
    };
  };
}
