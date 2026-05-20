# Shared, machine-local path values.
#
# Home Manager modules that need to reference files inside the nix-config
# repo as *live, mutable paths* (i.e. outside the Nix store) should read
# `config.local.repoPath` instead of hard-coding an absolute path or
# relying on `toString ./relative.path` (which silently resolves into the
# read-only flake source in /nix/store).
#
# Typical use:
#
#     let settingsPath = "${config.local.repoPath}/user-config/modules/X/settings.json";
#     in {
#       xdg.configFile."X/settings.json".source =
#         config.lib.file.mkOutOfStoreSymlink settingsPath;
#     }
{ config, lib, ... }:
{
  options.local = {
    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Coding/github.com/rytswd/nix-config";
      description = ''
        Absolute filesystem path to the nix-config repo checkout on this
        machine. Used as the base for `mkOutOfStoreSymlink` targets and
        any other module that needs to reach back into the repo as a
        live (mutable) path rather than via the Nix store.

        The default assumes the conventional location
        `$HOME/Coding/github.com/rytswd/nix-config`. Override per-host if
        your checkout lives elsewhere.
      '';
      example = "/srv/nix-config";
    };
  };
}
