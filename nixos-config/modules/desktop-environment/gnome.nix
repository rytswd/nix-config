{ pkgs
, lib
, config
, ...}:

{
  options = {
    desktop-environment.gnome.enable = lib.mkEnableOption "Enable GNOME.";
  };

  config = lib.mkIf config.desktop-environment.gnome.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [
        pkgs.mutter
      ];
      # extraGSettingsOverrides = ''
      #   [org.gnome.desktop.input-sources]
      #   sources=[('xkb', 'us+dvorak'), ('xkb', 'us'), ('xkb', 'jp')]
      # '';
    };
  };
}
