{
  config,
  inputs,
  self,
  ...
}:

let
  # Live, out-of-store path so the Noctalia UI can write to settings.json.
  # `config.local.repoPath` is declared in `user-config/modules/lib/paths.nix`
  # and defaults to the conventional checkout location; override per-host
  # if the repo lives elsewhere.
  #
  # NB: `toString ./settings.json` would *look* equivalent but silently
  # resolves into the read-only flake source under /nix/store.
  settingsPath = "${config.local.repoPath}/user-config/modules/appearance/noctalia/settings.json";
in
{
  imports = [
    # `local.repoPath` is declared here. The module system deduplicates
    # this import with any caller that also pulls it in directly.
    "${self}/user-config/modules/lib/paths.nix"
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    # Autostart is handled by the compositor (niri spawn-at-startup /
    # hyprland exec-once running `noctalia-shell`); the systemd service is
    # deprecated upstream.
    #
    # NOTE: `settings` is intentionally omitted here.
    # Setting it would make ~/.config/noctalia/settings.json a read-only
    # Nix store symlink, preventing the Noctalia UI from saving changes.
  };

  # NOTE: plugins are manually handled at the moment, I should fix it.

  # Use the same xdg.configFile attr that the upstream module uses,
  # but point it to a mutable out-of-store symlink instead.
  # This avoids duplicate definition conflicts with the module's own entry.
  xdg.configFile."noctalia/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink settingsPath;
  };
}
