# Stripped-down NixOS profile for VM guests (UTM / Parallels on Apple
# Silicon -- `nixos-config/mbp-vm`).
#
# Same as ./nixos.nix minus the vendor product bundles that don't earn
# their keep inside a VM (music/collaboration vendors, product VCS
# apps). Kept as its own file -- rather than inline `disabledModules` at
# each consumer -- so the embedded HM wiring in
# `nixos-config/mbp-vm/default.nix` and the standalone
# `homeConfigurations."ryota@nixos-{utm,parallels}"` entries stay in
# lockstep by construction.
{ self, ... }:
{
  imports = [
    ./nixos.nix
  ];

  # The paths below match exactly how they appear in ./nixos.nix's
  # `imports` list (bare directory paths -- module-system
  # canonicalisation resolves them to each bundle's `default.nix`).
  disabledModules = [
    "${self}/user-config/modules/product/vcs"
    "${self}/user-config/modules/product/collaboration"
    "${self}/user-config/modules/product/music"
  ];
}
