# NOTE: This is old and no longer used / referenced.

# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      # NOTE: It's not that I'm making a mistake with the syntax here, but the main problem seems to be that. When I reset, I get everything rolled back, unless it's provided as a part of dconf settings in nixos configuration. Rebuild works, so there is something else in this...
      sources = [
        (mkTuple [ "xkb" "us+dvorak" ])
        (mkTuple [ "xkb" "jp" ])
        # (mkTuple [ "xkb" "us" ])
      ];
      xkb-options = [ "ctrl:nocaps" "altwin:swap_alt_win" "grp:win_space_toggle" ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-key-theme = "Emacs";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 195;
      repeat-interval = mkUint32 13;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = [];
      close = [ "<Shift><Super>comma" ];
      maximize = [ "<Control><Alt>Page_Up" ];
      unmaximize = [ "<Control><Alt>Page_Down" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "";
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Control><Alt>Home" ];
      toggle-tiled-right = [ "<Control><Alt>End" ];
    };

    "org/gnome/nautilus/preferences" = {
      migrated-gtk-settings = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      search = [ "<Alt>space" ];
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };
  };
}
