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
    codeRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Coding";
      description = ''
        Base directory under which all my source checkouts live, grouped
        by forge below it (`<codeRoot>/github.com/...`, with room for other
        forges later). `local.ghRoot` is derived from this.

        Defaults to `$HOME/Coding`. Override per-host where checkouts live
        elsewhere -- e.g. coder/devspace workspaces use `$HOME/src` (a
        persistent volume), since the rest of `$HOME` is wiped on restart.
      '';
      example = "/root/src";
    };
    binRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.local.codeRoot}/bin";
      description = ''
        Directory of ad-hoc personal executables to put on PATH (scripts /
        one-off binaries that are NOT managed by Nix). Derived from
        `local.codeRoot` so the default follows wherever source checkouts
        live (`$HOME/Coding/bin` on personal machines).

        Override per-host where the persistent scratch area differs --
        e.g. coder workspaces keep `$HOME` ephemeral but mount a
        persistent volume at `$HOME/home`, so `binRoot` becomes
        `$HOME/home/bin` there.
      '';
      example = "/root/home/bin";
    };
    goRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.local.codeRoot}/go";
      description = ''
        Go workspace root: GOPATH points here, so `go install` artifacts
        land in `<goRoot>/bin` (which programming/go.nix puts on PATH)
        and the module cache lives under `<goRoot>/pkg`. Derived from
        `local.codeRoot` so the default follows wherever source checkouts
        live (`$HOME/Coding/go` on personal machines, unchanged from
        before this option existed).

        Split out from `local.codeRoot` because the Go tree is not a
        forge checkout, so hosts that keep `codeRoot` strictly for
        checkouts can move it independently -- e.g. coder workspaces keep
        `$HOME` ephemeral but mount a persistent volume at `$HOME/home`,
        so `goRoot` becomes `$HOME/home/go` there and installed tools
        survive a workspace recycle.
      '';
      example = "/root/home/go";
    };
    ghRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.local.codeRoot}/github.com";
      description = ''
        Directory holding GitHub-hosted checkouts, laid out as
        `<ghRoot>/<owner>/<repo>` (e.g. `<ghRoot>/rytswd/nix-config`,
        `<ghRoot>/withre/air`). `local.repoPath` and the local-skill paths
        in `llm/skills.nix` derive from this.

        Split out from `local.codeRoot` because most of my repos live on
        GitHub today, but could move to another forge later without
        disturbing the `codeRoot` base or per-host overrides.
      '';
      example = "/root/src/github.com";
    };
    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.local.ghRoot}/rytswd/nix-config";
      description = ''
        Absolute filesystem path to the nix-config repo checkout on this
        machine. Used as the base for `mkOutOfStoreSymlink` targets and
        any other module that needs to reach back into the repo as a
        live (mutable) path rather than via the Nix store.

        Derived from `local.ghRoot` by default (the conventional
        `$HOME/Coding/github.com/rytswd/nix-config`). Override per-host if
        my checkout lives elsewhere.
      '';
      example = "/srv/nix-config";
    };
  };
}
