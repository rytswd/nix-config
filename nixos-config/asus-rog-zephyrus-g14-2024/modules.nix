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
  ...
}:
[
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    # disko defines the partition and filesystem setup.
    # NOTE: disko isn't used for this machine -- partitions and filesystems
    # are managed by hardware.nix's fileSystems entries directly.
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
    ##  User Setup
    #------------------------------------------
    # Create users.
    "${self}/user-config/admin/create.nix"
    "${self}/user-config/ryota/create.nix"

    inputs.nix-config-private.nixosModules.users

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager
    "${self}/shared/home-manager.nix"
    {
      home-manager.users.admin.imports = [
        "${self}/user-config/admin/nixos.nix"
      ];
      home-manager.users.ryota.imports = [
        "${self}/user-config/ryota/nixos.nix"
      ];
    }
  ]
