{ pkgs, lib, ... }:
{
  services.xserver.enable = true;

  services.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverridePackages = [
      pkgs.mutter
    ];
    # extraGSettingsOverrides = ''
    #   [org.gnome.desktop.input-sources]
    #   sources=[('xkb', 'us+dvorak'), ('xkb', 'us'), ('xkb', 'jp')]
    # '';
  };

  # Use `pass-secret-service` (home-manager) as the sole provider of
  # `org.freedesktop.secrets`. The GNOME desktop module defaults
  # gnome-keyring on, so force-disable it here -- otherwise both daemons
  # race for the D-Bus name and one of them silently loses.
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # GNOME defaults `i18n.inputMethod` to ibus, which sets GTK_IM_MODULE=ibus
  # and QT_IM_MODULE=ibus in /etc/set-environment. That conflicts with the
  # fcitx5 setup configured per-user via home-manager
  # (`user-config/modules/i18n/japanese.nix`). Force the system-level input
  # method off so the home-manager fcitx5 service is the only IM provider.
  i18n.inputMethod.enable = lib.mkForce false;

  # Remove the local indexing, as this is adding extra load to the machine
  # unnecessarily, as I don't really use the file indexing.
  services.gnome.localsearch.enable = false;
}
