{ pkgs, ... }:
# Hyprland -- not imported by the window-manager bundle's default.nix. Import
# this leaf directly from a host config when I want it.
{
  wayland.windowManager.hyprland = {
    enable = true;

    # Pinned explicitly: home-manager flipped this default from "hyprlang" to
    # "lua" in 26.05, and only keeps the legacy value while
    # `home.stateVersion` is older -- which it warns about on every eval.
    # Everything here is hyprlang (the `source=` line below plus the whole
    # ./config tree), so "lua" would write a hyprland.lua and treat
    # `extraConfig` as raw Lua. Stating the legacy value silences the warning
    # without changing behaviour; switching to "lua" is a full rewrite of
    # ./config, not a flag flip.
    configType = "hyprlang";

    # This assumes that the below XDG config is mapped to provide extra conf
    # file, which can refer to as a relative path.
    extraConfig = ''
      source=./hyprland-custom.conf
    '';

    # TODO: Add extra handling so that extra files can be added based on
    # the machine requirements (Asus will need specific resolution
    # handling, whereas UTM won't need it.)
    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    ];
  };

  services.hyprshell = {
    enable = false;
    systemd.args = "-v";
    settings = {
      version = 3;
      windows = {
        scale = 8.5;
        items_per_row = 5;
        overview = {
          key = "super_l";
          modifier = "super";
          launcher = {
            default_terminal = "alacritty";
          };
        };
        switch = {
          modifier = "alt";
        };
      };
    };
  };

  # Because the config is quite lengthy, I'm simply mapping a file into the
  # XDG directory.
  xdg.configFile = {
    "hypr/".source = ./config;
    "hypr/".recursive = true;
  };

  home.packages = [
    pkgs.hypridle
    pkgs.hyprlock
  ];
}
