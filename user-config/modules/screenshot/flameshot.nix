# Flameshot -- https://github.com/flameshot-org/flameshot
#
# NOTE: Wayland support is limited. Not imported by the bundle's default.nix;
# import this leaf directly from a host config when needed.
{
  services.flameshot = {
    enable = true;
    # Ref: https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
      };
    };
  };
}
