# Fix GNOME with xdg-desktop-portal
# Ref: https://github.com/NixOS/nixpkgs/pull/345979
# This has been merged, and no longer need this patch.

final: prev:

{
  xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (old: rec {
    buildInputs = [
      prev.glib
      prev.gtk3
      prev.xdg-desktop-portal
      prev.gsettings-desktop-schemas # settings exposed by settings portal
      prev.gnome-desktop
      prev.gnome-settings-daemon # schemas needed for settings api (mostly useless now that fonts were moved to g-d-s, just mouse and xsettings)
    ];
    mesonFlags = [];
  });
}
