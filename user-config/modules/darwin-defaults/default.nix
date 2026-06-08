# macOS user-level preferences via Home Manager.
#
# Uses `targets.darwin.defaults.<domain>` which writes to user-scoped
# preference plists (NSGlobalDomain, Dock, Finder, etc.) during HM
# activation. Equivalent to nix-darwin's `system.defaults.*` but applied
# at HM activation time, so changes don't require a system rebuild.
#
# Only the bundle entry is meant to be imported; each sub-module below
# is independently importable too if you want a narrow slice.
{ ... }:
{
  imports = [
    ./nsglobaldomain.nix
    ./dock.nix
    ./finder.nix
    ./trackpad.nix
  ];
}
