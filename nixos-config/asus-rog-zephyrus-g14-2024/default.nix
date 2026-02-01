{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  ...
}:

nixpkgs.lib.nixosSystem rec {
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
    inputs.disko.nixosModules.disko
    # NOTE: This is not using impermanence.
    # inputs.impermanence.nixosModules.impermanence
    # ../modules/nix-impermanence.nix

    inputs.sops-nix.nixosModules.sops
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    # Adjust Nix and Nixpkgs related flags before proceeding.
    ../modules/nix-base.nix

    ###----------------------------------------
    ##  Main Configuration
    #------------------------------------------
    # disko defines the partition and filesystem setup.
    # NOTE: disko isn't used for this machine.
    # ./disko.nix
    # hardware.nix has some hardware specific configurations.
    ./hardware.nix
    # configuration.nix pulls in various modules to achieve similar
    # configuration across machines.
    ./configuration.nix

    # Create users.
    ../../user-config/admin/create.nix
    # ../../user-config/admin/persist-impermanence.nix

    ../../user-config/ryota/create.nix
    # ../../user-config/ryota/persist-impermanence.nix

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
        users = {
          admin = ../../user-config/admin/nixos.nix;
          ryota = ../../user-config/ryota/nixos.nix;
        };
      };
    }
  ];
}
