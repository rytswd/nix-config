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
  # gnome-keyring on, so force-disable it here — otherwise both daemons
  # race for the D-Bus name and one of them silently loses.
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Remove the local indexing, as this is adding extra load to the machine
  # unnecessarily, as I don't really use the file indexing.
  services.gnome.localsearch.enable = false;
}
