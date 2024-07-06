{ pkgs
, lib
, config
, inputs
, system
, ...}:

{
  options = {
    window-manager.hyprland.enable = lib.mkEnableOption "Enable Hyprland user settings.";
  };

  config = lib.mkIf config.window-manager.hyprland.enable {
    wayland = {
      windowManager = {
        hyprland = {
          enable = true;
          # This assumes that the above XDG config is mapped to provide extra conf
          # file, which can refer to as a relative path.
          extraConfig = ''
            source=./hyprland-custom.conf
          '';
          # TODO: Add extra handling so that extra files can be added based on
          # the machine requirements (Asus will need specific resolution
          # handling, whereas UTM won't need it.)
          plugins = [
            # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock
          ];
        };
      };
    };

    # Because the config is quite lengthy, I'm simply mapping a file into the
    # XDG directory.
    xdg = {
      configFile = {
        "hypr/".source = ./hyprland-config;
        "hypr/".recursive = true;
      };
    };

    home.packages = [
      inputs.hyprswitch.packages.${system}.default
    ];
  };
}
