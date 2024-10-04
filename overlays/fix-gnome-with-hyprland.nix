# Ref: https://github.com/NixOS/nixpkgs/pull/345979
# Once this is merged, I shouldn't need this.

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
