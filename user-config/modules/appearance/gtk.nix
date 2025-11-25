{ pkgs
, lib
, config
, ...}:

{
  options = {
    appearance.gtk.enable = lib.mkEnableOption "Enable GTK.";
  };

  config = lib.mkIf config.appearance.gtk.enable {
    gtk = {
      enable = true;

      # NOTE: All of the below is using GTK3.

      # Use libadwaita, and specify dark theme.
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3-dark";
      };

      # NOTE: I took this from somewhere, I don't really care too much.
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };

      gtk3 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
          # NOTE: This sets the Emacs based key bindings such as C-a to go to the
          # beginning of line.
          gtk-key-theme-name = "Emacs";
          # TODO: This is commented out for now.
          # gtk-im-module = "fcitx";
        };
        # extraCss = ''
        #   @binding-set MyCustomBindings {
        #    bind "<Meta>j" { "copy-clipboard" () };
        #   }

        #   * {
        #     gtk-key-bindings: MyCustomBindings;
        #   }
        # '';
      };


      gtk4 = {
        # colorScheme = "dark";
        extraConfig = {
          gtk-interface-color-scheme = "dark";
          gtk-application-prefer-dark-theme = true;
        };
      };
    };
  };
}
