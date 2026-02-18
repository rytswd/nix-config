{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  ...
}:

nixpkgs-unstable.lib.nixosSystem rec {
  inherit system;
  specialArgs = {
    inherit
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
    inputs.disko.nixosModules.disko
    inputs.disko-zfs.nixosModules.default
    # I'm choosing to support dual boot.
    ./disko-dual-boot.nix
    # ./disko-nixos-only.nix

    # Impermanence makes the whole disk ephemeral unless otherwise specified.
    inputs.impermanence.nixosModules.impermanence
    ../modules/nix-impermanence.nix

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
    # inputs.nix-config-private.nixos-modules.civo

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
    # Adjust Nix and Nixpkgs related flags before proceeding.
    ../modules/nix-base.nix
    # hardware.nix has some hardware specific configuration for this device.
    ./hardware.nix
    # configuration.nix pulls in various modules to achieve similar
    # configuration across machines.
    ./configuration.nix

    ###----------------------------------------
    ##  User Setup
    #------------------------------------------
    # Create users.
    ../../user-config/admin/create.nix
    ../../user-config/ryota/create.nix

    inputs.nix-config-private.nixosModules.users

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        # NOTE: Without this, I get an error applying home-manager updates
        # (following the addition of GTK config).
        backupFileExtension = "backup";
        useGlobalPkgs = false;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };

        # Set nixpkgs config for all home-manager users
        sharedModules = [{
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = overlays;
        }];

        # Each user needs to be set up separately.
        # Because home-manager needs to know where the home directory is,
        # I need to specify the username again.

        users.admin = {
          imports = [
            # Impermanence setup enabled for this device.
            ../../user-config/admin/persist-impermanence.nix
            ../../user-config/admin/nixos.nix
          ];
        };
        users.ryota =  {
          imports = [
            # Impermanence setup enabled for this device.
            ../../user-config/ryota/persist-impermanence.nix
            ../../user-config/ryota/nixos.nix
          ];
        };
      };
    }
  ];
}
