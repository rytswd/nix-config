{ pkgs
, lib
, config
, ...}:

{
  options = {
    desktop-environment.gnome.dconf.enable = lib.mkEnableOption "Enable GNOME dconf.";
  };

  config = lib.mkIf config.desktop-environment.gnome.dconf.enable {
    # Ensure dconf is taken into account from NixOS startup.
    programs.dconf = {
      enable = true;
      profiles.user.databases = with lib.gvariant; [
        {
          settings = {
            # "com/raggesilver/BlackBox" = {
            #   opacity = mkUint32 100;
            #   theme-dark = "Tommorow Night";
            #   scrollback-lines = mkUint32 10000;
            # };
            "org/gnome/desktop/input-sources" = {
              mru-sources = [
                (mkTuple [ "xkb" "us+dvorak" ])
                (mkTuple [ "xkb" "us" ])
                (mkTuple [ "xkb" "jp" ])
              ];
              sources = [
                (mkTuple [ "xkb" "us+dvorak" ])
                (mkTuple [ "xkb" "us" ])
                (mkTuple [ "xkb" "jp" ])
              ];
              xkb-options = [ "terminate:ctrl_alt_bksp" ];
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
            };
          };
          # locks = [
          #   "/com/raggesilver/BlackBox/theme-dark"
          # ];
        }
      ];
    };
  };
}
