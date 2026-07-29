# The machine's module list, split out so it can be evaluated two ways:
# built here as a plain nixosSystem (./default.nix), or wrapped by another
# flake that adds modules of its own -- e.g. a clan inventory contributing
# mesh membership. Keeping the list in one place means both paths build the
# same machine, and neither can drift from the other.
{
  self,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  variant,
  ...
}:
[
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
  ]
