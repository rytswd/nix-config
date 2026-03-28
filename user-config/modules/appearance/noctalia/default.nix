{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.appearance.noctalia;
  # toString prevents Nix from copying the path into the store,
  # keeping it as a plain string of the absolute path.
  settingsPath = toString ./settings.json;
in
{
  options.appearance.noctalia = {
    enable = lib.mkEnableOption "Noctalia shell";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      # NOTE: `settings` is intentionally omitted here.
      # Setting it would make ~/.config/noctalia/settings.json a read-only
      # Nix store symlink, preventing the Noctalia UI from saving changes.
    };

    # Use the same xdg.configFile attr that the upstream module uses,
    # but point it to a mutable out-of-store symlink instead.
    # This avoids duplicate definition conflicts with the module's own entry.
    xdg.configFile."noctalia/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink settingsPath;
    };
  };
}
