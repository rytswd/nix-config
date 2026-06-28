{ self, lib, nixpkgs }:
# CI-friendly per-host derivations.
#
# Exposes every nixosConfigurations / darwinConfigurations entry as a
# derivation under `checks.<system>.<prefix>-<name>` so that
#
#     nix flake check --all-systems --no-build
#
# validates every host can at least evaluate, and
#
#     nix flake check
#
# actually builds them on the current system. The `installer-iso` host is
# excluded because it pulls in a full ISO build and a known wireless option
# conflict; build it explicitly via `nix build .#installer-iso` instead.
#
# Pattern borrowed from Mic92/dotfiles' `checks/flake-module.nix`, written
# imperatively here (no flake-parts dependency).
#
# `private-stub-interface` is the drift guard for stubs/nix-config-private:
# every `inputs.nix-config-private.<attr>` referenced in this repo must
# exist in the stub's outputs, so the stub stays an honest public record of
# the private interface. Note that *selecting* any single check by name
# still forces eval of every host's `pkgs` (the filterBySystem predicate
# below), which in turn forces the private input -- so run it with the stub
# override, fittingly the very thing it verifies:
#
#     nix build .#checks.x86_64-linux.private-stub-interface \
#         --override-input nix-config-private path:./stubs/nix-config-private
let
  systems = [
    "x86_64-linux"
    "aarch64-linux" # nixos-utm
    "aarch64-darwin"
  ];

  blacklist = [
    "installer-iso" # heavy build, pre-existing eval conflict
  ];

  filterBySystem =
    system: configs:
    lib.filterAttrs (_n: cfg: (cfg.pkgs.stdenv.hostPlatform.system or null) == system) configs;

  mkChecksForSystem =
    system:
    let
      nixosForSys = filterBySystem system (lib.removeAttrs self.nixosConfigurations blacklist);
      darwinForSys = filterBySystem system self.darwinConfigurations;
    in
    # nixos-<host> -> system toplevel
    (lib.mapAttrs' (n: cfg: lib.nameValuePair "nixos-${n}" cfg.config.system.build.toplevel) nixosForSys)
    //
      # darwin-<host> -> activation system
      (lib.mapAttrs' (n: cfg: lib.nameValuePair "darwin-${n}" cfg.system) darwinForSys);
  # home-<host>-<user> deliberately omitted until the standalone
  # `user-config/home-manager/` entry point is restored; the existing
  # `homeConfigurations` output references a path that does not exist.

  ###----------------------------------------
  ##  Private-stub interface drift guard
  #------------------------------------------
  # The stub's outputs, flattened to `<group>.<name>` attr paths. Two levels
  # is the entire consumed shape today; a deeper in-repo reference shows up
  # as "missing" below, which is the right failure mode -- it means the stub
  # must learn the new shape. The bare `toString inputs.nix-config-private`
  # usage (a file path, not an attr) is out of scope here; the stub's
  # keys/ssh/yubikey-stub.yaml documents that part of the surface.
  stubInterface =
    let
      stub = (import ./stubs/nix-config-private/flake.nix).outputs { self = { }; };
    in
    lib.concatMap (g: map (n: "${g}.${n}") (lib.attrNames stub.${g})) (lib.attrNames stub);

  mkStubInterfaceCheck =
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      provided = pkgs.writeText "stub-interface" (lib.concatMapStrings (s: s + "\n") stubInterface);
    in
    pkgs.runCommand "private-stub-interface" { } ''
      set -euo pipefail

      # Every attr-path reference to the private input in tracked nix files,
      # minus the stub itself and comment-only lines (host configs keep
      # commented-out references like `nixos-modules.work` around).
      if ! grep -RnE 'inputs\.nix-config-private\.' \
            --include='*.nix' --exclude-dir=stubs ${self} > raw.txt; then
        echo "private-stub-interface: found NO inputs.nix-config-private.<attr>" >&2
        echo "references at all -- the grep pattern or the repo layout broke." >&2
        exit 1
      fi
      grep -vE '^[^:]+:[0-9]+:[[:space:]]*#' raw.txt \
        | grep -oE 'inputs\.nix-config-private(\.[A-Za-z0-9_-]+)+' \
        | sed 's/^inputs\.nix-config-private\.//' \
        | sort -u > used.txt

      sort -u ${provided} > provided.txt

      if ! comm -23 used.txt provided.txt > missing.txt || [ -s missing.txt ]; then
        echo "private-stub-interface: attrs consumed in-repo but absent from" >&2
        echo "stubs/nix-config-private/flake.nix (grow the stub's no-op in the" >&2
        echo "same change that introduced the reference):" >&2
        sed 's/^/  inputs.nix-config-private./' missing.txt >&2
        exit 1
      fi

      echo "stub interface covers all in-repo references:"
      cat used.txt
      touch $out
    '';
in
lib.genAttrs systems (
  system: mkChecksForSystem system // { private-stub-interface = mkStubInterfaceCheck system; }
)
