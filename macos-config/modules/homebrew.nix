# Homebrew base configuration.
#
# This module enables Homebrew and sets activation policy. Individual
# casks/brews live in their own per-item modules under
# `macos-config/modules/<category>/<name>.nix` and are imported per host
# as needed (the macOS profile imports none by default – stays minimal).
#
# NB: SrvOS's `darwinModules.common` (imported in the profile) sets
# `homebrew.onActivation.cleanup = lib.mkDefault "uninstall"`. With that
# active, **any brew app not declared via these modules will be
# uninstalled on activation**. Audit installed brews before first deploy.
{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # `cleanup` is set to "uninstall" by SrvOS's `darwinModules.common`.
      # Override with `lib.mkForce "none"` per-host during transition if
      # an audit pass hasn't happened yet.
    };

    global.autoUpdate = false;
  };

  # Disable Homebrew analytics + env hints for every brew/cask invocation
  # without relying on per-user shell rc files.
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };
}
