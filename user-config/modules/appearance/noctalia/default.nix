{
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    # Autostart is handled by the compositor (niri spawn-at-startup /
    # hyprland exec-once running `noctalia`); the systemd user service is
    # left off (`systemd.enable` defaults to false upstream).

    # Declarative base config, written read-only to
    # ~/.config/noctalia/config.toml and validated at build time with
    # `noctalia config validate` (validateConfig defaults to true). The GUI
    # layers runtime overrides on top in ~/.local/state/noctalia/settings.toml
    # (state dir), which Nix never touches -- so the shell stays adjustable.
    settings = ./config.toml;

    # Custom M3 palette -> ~/.config/noctalia/palettes/Rytswd.json. Inactive
    # while [theme].source = "wallpaper"; set source = "custom" and
    # custom_palette = "Rytswd" in config.toml to switch to it.
    customPalettes.Rytswd = ./palettes/Rytswd.json;
  };
}
