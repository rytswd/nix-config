# `bootstrap` flake app -- single-command coder/devspace setup.
#
# Mirrors Mic92/dotfiles' `bootstrap-dotfiles` app, but flake-native: there
# is no homeshick step because this repo is consumed directly as a flake.
#
# This is wired as `apps.<system>.default`, so a fresh coder workspace can
# bring up the full standalone Home Manager profile with a single command:
#
#     nix run github:rytswd/nix-config
#
# (equivalently `nix run github:rytswd/nix-config#bootstrap`, or
# `nix run .#bootstrap` from a checkout).
#
# What it does, in order:
#   1. Resolve the HM profile from the CPU arch -- `coder` on x86_64,
#      `coder-aarch64` on aarch64. An explicit profile can be passed as
#      the first argument to override.
#   2. Pin any pre-seeded nix profile as its own GC root (coder images ship
#      a seeded store; this keeps those paths alive through the first GC).
#      Safe no-op on non-coder hosts.
#   3. `home-manager switch --flake <self>#<profile> -b backup`.
#
# `<self>` is the flake's own source (this very revision), so a remote
# `nix run github:rytswd/nix-config` and a local `nix run .#bootstrap`
# both build from the exact tree the app was evaluated from.
#
# For day-to-day updates after the first run, prefer the lighter `hm`
# dispatcher (`nix run .#hm -- switch`).
{ pkgs, self }:

let
  bootstrap = pkgs.writeShellApplication {
    name = "bootstrap-coder";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
      # For the best-effort `gh auth token` lookup in bootstrap.sh. Reads the
      # workspace owner's existing gh auth (shared config dir + keyring), so no
      # extra login needed; harmless when gh is logged out.
      pkgs.gh
    ];
    # Inject the flake's own store path so the script switches against the
    # same revision it was built from.
    text = ''
      FLAKE_REF="${self}"
      export FLAKE_REF
    ''
    + builtins.readFile ./bootstrap.sh;
  };
in
{
  type = "app";
  program = "${bootstrap}/bin/bootstrap-coder";
}
