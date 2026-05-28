{ pkgs, ... }:
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

  # Remove the local indexing, as this is adding extra load to the machine
  # unnecessarily, as I don't really use the file indexing.
  services.gnome.localsearch.enable = false;
}
