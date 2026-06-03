{ self, lib }:
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
in
lib.genAttrs systems mkChecksForSystem
