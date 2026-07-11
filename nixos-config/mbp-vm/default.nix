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
}:

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
  modules = [
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    # disko defines the partition and filesystem setup.
    # NOTE: disko isn't used for this machine -- the disk is prepared by
    # `machine-setup/mbp-utm/prepare-vm.sh` (works for both hypervisors)
    # and `hardware.nix` mounts it by label.
    # inputs.disko.nixosModules.disko
    # ./disko.nix

    # NOTE: This machine doesn't use impermanence.
    # inputs.impermanence.nixosModules.impermanence
    # "${self}/nixos-config/modules/nix-impermanence.nix"

    ###----------------------------------------
    ##  Third party solutions
    #------------------------------------------
    inputs.sops-nix.nixosModules.sops
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    ###----------------------------------------
    ##  Extra configuration
    #------------------------------------------
    # Extra modules based on private setup.
    # inputs.nix-config-private.nixos-modules.work

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
    # Adjust Nix and Nixpkgs related flags before proceeding.
    "${self}/nixos-config/modules/nix-base.nix"
    # hardware.nix has some hardware specific configuration for this device.
    ./hardware.nix
    # configuration.nix pulls in various modules to achieve similar
    # configuration across machines.
    ./configuration.nix

    ###----------------------------------------
    ##  Hypervisor variant
    #------------------------------------------
    # Guest-tools leaf for the hosting hypervisor (UTM: spice-webdavd +
    # QEMU quirks; Parallels: prl-tools). The generic QEMU-guest baseline
    # is imported by configuration.nix for both.
    "${self}/nixos-config/modules/virtual-machine/${variant}.nix"
    {
      # NOTE: This should match the name used for nixosConfigurations, so
      # that nh tool can automatically find the right target.
      networking.hostName = "nixos-${variant}";
    }

    ###----------------------------------------
    ##  User Setup
    #------------------------------------------
    # Create users.
    # `admin` is created alongside `ryota` because the private users module
    # (`nix-config-private.nixosModules.users`) attaches a hashedPassword to
    # `users.users.admin` unconditionally, which requires the admin user to
    # actually be declared. Cheap to keep -- it's a wheel-capable rescue
    # account, useful in a VM you might brick.
    # TODO: Remove the admin user which won't have much use in VM env.
    "${self}/user-config/admin/create.nix"
    "${self}/user-config/ryota/create.nix"

    inputs.nix-config-private.nixosModules.users

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager
    "${self}/shared/home-manager.nix"
    {
      # Stripped-down VM profile -- nixos.nix minus the vendor product
      # bundles. Shared with the standalone
      # `homeConfigurations."ryota@nixos-{utm,parallels}"` entries so
      # embedded and standalone HM stay in lockstep.
      home-manager.users.ryota.imports = [
        "${self}/user-config/ryota/vm.nix"
      ];
    }
  ];
}
