# `install` flake app -- guided bare-metal NixOS installer.
#
# Runnable from the custom installer ISO (nixos-config/iso/) or a stock
# NixOS installer ISO -- the script sets NIX_CONFIG itself, so the stock
# image's lack of flake support does not matter:
#
#     nix run github:rytswd/nix-config#install -- [--dry-run] [<host>]
#
# Phases, each printing its underlying command before running and asking
# for explicit confirmation:
#   1. network check
#   2. credential preflight (apps/lib/preflight.sh; the verdict picks full
#      vs degraded eval -- degraded substitutes stubs/nix-config-private)
#   3. repo clone to /tmp (skipped when already inside a checkout)
#   4. disko -- per-host layout/mode chosen explicitly; a destructive mode
#      is never the default
#   5. nixos-install --flake (with the stub override when degraded)
#   6. post-install checklist (printed, never executed)
#
# The runbook docs/runbooks/bare-metal-install.org holds the why; this app
# is the how. `--dry-run` walks every phase printing the commands and
# executes only the read-only probes.
#
# `<self>` is the flake's own source (this very revision), so a remote
# `nix run github:rytswd/nix-config#install` and a local `nix run
# .#install` both resolve hosts and the preflight library from the exact
# tree the app was evaluated from.
{ pkgs, self }:

let
  install = pkgs.writeShellApplication {
    # Not plain `install` (coreutils) nor `nixos-install` (the real
    # installer this wraps) -- both would shadow on PATH.
    name = "nixcfg-install";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.nix
      # Network probe only -- everything else flows through nix/git.
      pkgs.curl
    ];
    # Inject the flake's own store path so host resolution and the
    # preflight library come from the same revision this app was built
    # from.
    text = ''
      FLAKE_REF="${self}"
      export FLAKE_REF
    ''
    + builtins.readFile ./install.sh;
  };
in
{
  type = "app";
  program = "${install}/bin/nixcfg-install";
}
