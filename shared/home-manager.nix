# Common home-manager integration settings, shared by every NixOS and
# nix-darwin host. Per-host blocks still set extraSpecialArgs and users.*.
{ ... }:
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
  };
}
