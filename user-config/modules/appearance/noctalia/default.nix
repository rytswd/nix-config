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
    # hyprland exec-once running `noctalia`); the systemd service is left off.
    #
    # `settings` is intentionally omitted: GUI changes are persisted to
    # ~/.local/state/noctalia/settings.toml (state dir), which Nix never
    # touches -- so the GUI stays writable without the out-of-store symlink
    # workaround v4 needed. Declarative base config could go in `settings`
    # (written read-only to ~/.config/noctalia/config.toml) if wanted later.
  };
}
