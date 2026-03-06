{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    appearance.dconf.enable = lib.mkEnableOption "Enable dconf settings.";
  };

  config = lib.mkIf config.appearance.dconf.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
      };
    };
  };
}
