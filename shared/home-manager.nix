# Common home-manager integration settings, shared by every NixOS and
# nix-darwin host that embeds HM in the system build. Hosts import this
# right after the HM module line and only declare the user -> profile
# mapping:
#
#     home-manager.nixosModules.home-manager   # (or .darwinModules)
#     "${self}/shared/home-manager.nix"
#     { home-manager.users.ryota.imports = [ "${self}/user-config/ryota/<profile>.nix" ]; }
#
{
  self,
  inputs,
  nixpkgs-unstable,
  overlays,
  pkgs,
  ...
}:
{
  home-manager = {
    # Back up a pre-existing file instead of aborting the switch when
    # home-manager wants to write a path that already exists on disk (e.g. a
    # karabiner.json the app created, or GTK config).
    backupFileExtension = "backup";
    # Use the system's pkgs rather than home-manager's own nixpkgs.
    useGlobalPkgs = true;
    # Install user packages under /etc/profiles/per-user/$USER.
    useUserPackages = true;

    # NOTE: useGlobalPkgs would normally hand HM the system pkgs; the
    # explicit `pkgs` below takes precedence, pointing HM at
    # nixpkgs-unstable regardless of what the system tracks (stable on the
    # NixOS hosts, unstable on darwin -- where this import is equivalent to
    # the global pkgs, kept anyway so all hosts share one wiring). The
    # config flags mirror the standalone mkHome wiring in flake.nix so
    # embedded and standalone switches see the same package set.
    extraSpecialArgs = {
      inherit self inputs;
      pkgs = import nixpkgs-unstable {
        # Target platform comes from the system pkgs -- no separate
        # `system` plumbing through specialArgs needed.
        inherit (pkgs.stdenv.hostPlatform) system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = overlays;
      };
    };
  };
}
