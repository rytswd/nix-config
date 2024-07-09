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
      profiles.ryota.databases = with lib.gvariant; [
        {
          settings = {
            # "org/gnome/shell" = {
            #   disable-user-extensions = false;
            #   enabled-extensions = with pkgs.gnomeExtensions; [
            #     paperwm.extensionUuid
            #   ];
            # };
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
                (mkTuple [ "xkb" "de" ])
              ];
              sources = [
                (mkTuple [ "xkb" "us+dvorak" ])
                (mkTuple [ "xkb" "us" ])
                (mkTuple [ "xkb" "jp" ])
                (mkTuple [ "xkb" "de" ])
              ];
              xkb-options = [ "terminate:ctrl_alt_bksp,ctrl:nocaps,altwin:swap_alt_win,grp:win_space_toggle" ];
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
    environment.systemPackages = [ pkgs.gnomeExtensions.paperwm ];
  };
}
