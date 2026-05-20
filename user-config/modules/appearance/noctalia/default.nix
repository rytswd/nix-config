{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.appearance.noctalia;
  # Use a live, out-of-store path so the Noctalia UI can write to
  # settings.json. `config.local.repoPath` is declared in
  # `../../lib/paths.nix` and defaults to the conventional checkout
  # location; override per-host if the repo lives elsewhere.
  #
  # NB: `toString ./settings.json` would *look* like the same thing but
  # silently resolves into the read-only flake source under /nix/store.
  settingsPath = "${config.local.repoPath}/user-config/modules/appearance/noctalia/settings.json";
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
      systemd.enable = true;
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
