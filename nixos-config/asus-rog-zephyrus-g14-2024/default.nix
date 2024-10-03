{ lib
, nixpkgs
, nixpkgs-unstable
, nixosSystem
, home-manager
, system
, overlays
, inputs
, ...}:

nixosSystem rec {
  inherit system;
  specialArgs = { inherit lib nixpkgs nixpkgs-unstable home-manager overlays; };
  modules = [
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    # Adjust Nix and Nixpkgs related flags before proceeding.
    ./nix-flags.nix

    # Start with the hardware configuration around M1 VM first.
    ./hardware.nix

    # Manage system wide configurations here.
    ./configuration.nix

    # Create users.
    ../../user-config/ryota/create.nix
    # ../../user-config/rytswd/create.nix

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager {
      # NOTE: Without this, I get an error applying home-manager updates
      # (following the addition of GTK config).
      home-manager.backupFileExtension = "backup";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # home-manager.sharedModules = [
      #   # Placeholder
      # ];
      home-manager.extraSpecialArgs = { inherit inputs; };

      # Each user needs to be set up separately. Because home-manager needs to
      # know where the home directory is, I need to specify the username again.
      home-manager.users.ryota = ../../user-config/ryota/home-manager/nixos.nix;
    }
  ];
}
