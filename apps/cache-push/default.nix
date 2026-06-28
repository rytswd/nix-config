# `cache-push` flake app -- push built closures to the self-hosted binary
# cache (write path: niks3; read path: https://cache.rytswd.com straight off R2).
#
#     nix run .#cache-push -- <store-path|installable...>
#
# Thin wrapper over the niks3 upload client: resolve arguments to store
# paths, then `niks3 push` them against the server endpoint from the
# environment. The niks3 CLI is invoked via `nix run github:Mic92/niks3`
# rather than added as a flake input -- same rationale as nixos-anywhere in
# apps/provision: a provisioning-time tool that runs on the pushing machine
# only and is never part of any closure, so pinning it here would only add
# lockfile churn. The cost is interface drift risk against an unpinned main;
# the invocation below (`niks3 push [flags] <store-paths...>`, server URL
# from NIKS3_SERVER_URL, token from NIKS3_AUTH_TOKEN_FILE or the XDG
# default) was verified against cmd/niks3/main.go and cmdutil/cmdutil.go at
# upstream main, 2026-06-28 (CLI v1.7.0).
#
# Signing is deliberately not this app's concern: narinfos are signed at
# upload by the niks3 *server*, which holds the `cache.rytswd.com-1` secret key
# (`services.niks3.signKeyFiles` upstream) as a provisioner-class sops
# secret in the private repo, YubiKey-only recipients. No signing key
# material ever reaches this app or the pushing machine -- the pusher only
# holds the API token.
{ pkgs }:

let
  cache-push = pkgs.writeShellApplication {
    name = "cache-push";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
    ];
    text = builtins.readFile ./cache-push.sh;
  };
in
{
  type = "app";
  program = "${cache-push}/bin/cache-push";
}
