# `hm` flake app — standalone Home Manager dispatcher.
#
# Lets any host bootstrap or update its standalone Home Manager profile
# without needing a system rebuild, via
#
#     nix run .#hm -- switch
#     nix run .#hm -- build
#     nix run .#hm -- profile    # show resolved profile, no action
#
# Profile resolution precedence (Mic92 pattern):
#   1. `<user>-<host>` exact match
#   2. `<host>-<user>` exact match
#   3. `<host>` exact match
#   4. glob fallback (`coder-*`, `*-devspace-*`, `*-utm`)
#   5. failure (no implicit common fallback yet)
#
# NOTE: the homeConfigurations output in `flake.nix` currently points at a
# missing `./user-config/home-manager` path; the dispatcher itself is wired
# but actual `nix run .#hm -- switch` will only succeed once that entry
# point exists. The profile map below intentionally contains placeholders
# for hosts that don't yet have a homeConfiguration entry; uncomment / add
# them as those hosts come online.
{ pkgs }:

let
  dispatcher = pkgs.writeShellApplication {
    name = "hm";
    runtimeInputs = [ pkgs.coreutils pkgs.hostname pkgs.nix ];
    text = builtins.readFile ./dispatcher.sh;
  };
in {
  type = "app";
  program = "${dispatcher}/bin/hm";
}
