{
  self,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  # Which hypervisor hosts this VM. One config dir, two flake outputs:
  #   variant = "utm"       -> nixosConfigurations.nixos-utm
  #   variant = "parallels" -> nixosConfigurations.nixos-parallels
  # The hostname is derived as "nixos-${variant}" and must keep matching
  # the flake attribute name (nh finds the target by hostname; niri picks
  # `output-<hostname>.kdl` in user-config).
  variant,
  ...
}@machineArgs:

# Apple Silicon aarch64-linux NixOS VM on macOS, hosted by either UTM or
# Parallels Desktop. Configuration shape intentionally mirrors
# `nixos-config/asus-rog-flow-z13-2025/` and `asus-rog-zephyrus-g14-2024/`;
# the per-host differences (no disko / no impermanence / no Limine / no
# asus quirks / VM guest agents) are documented inside `configuration.nix`.
# The only per-hypervisor deltas are the guest-tools leaf selected below
# and the hostname.

assert nixpkgs.lib.assertOneOf "variant" variant [
  "utm"
  "parallels"
];

nixpkgs.lib.nixosSystem rec {
  inherit system;
  specialArgs = {
    inherit
      self
      inputs
      nixpkgs
      nixpkgs-unstable
      home-manager
      overlays
      ;
  };
  modules = import ./modules.nix machineArgs;
}
