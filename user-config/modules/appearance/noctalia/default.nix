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

    # Instead, create a mutable out-of-store symlink.
    # The JSON file lives in this directory and is symlinked directly (not
    # copied into the Nix store), so the Noctalia UI can read AND write it.
    home.file.".config/noctalia/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink settingsPath;
    };
  };
}
