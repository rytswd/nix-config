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
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    inputs.disko.nixosModules.disko
    # disko defines the partition and filesystem setup.
    # NOTE: disko isn't used for this machine.
    # ./disko.nix

    # NOTE: This is not using impermanence.
    # inputs.impermanence.nixosModules.impermanence
    # ../modules/nix-impermanence.nix

    ###----------------------------------------
    ##  Third party solutions
    #------------------------------------------
    inputs.sops-nix.nixosModules.sops
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
    # Adjust Nix and Nixpkgs related flags before proceeding.
    ../modules/nix-base.nix
    # hardware.nix has some hardware specific configurations.
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

        # Because of pkgs shadowing below, we technically don't need any
        # extra adjustment to global pkgs. Keeping this to true is
        # slightly cleaner.
        useGlobalPkgs = true;
        # Set to true for using /etc/profiles/per-user/username/ path.
        useUserPackages = true;

        # Update pkgs to point to nixpkgs-unstable.
        extraSpecialArgs = {
          inherit inputs;
          pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            overlays = overlays;
          };
        };

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
