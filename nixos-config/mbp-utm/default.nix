{ lib
, nixpkgs
, nixpkgs-unstable
, nixosSystem
, home-manager
, system
, ghostty
, overlays
, ...}:

nixosSystem rec {
  inherit system;
  specialArgs = { inherit lib nixpkgs nixpkgs-unstable home-manager ghostty overlays; };
  modules = [
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
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit system ghostty; }; #Temp

      # Each user needs to be set up separately. Because home-manager needs to
      # know where the home directory is, I need to specify the username again.
      home-manager.users.ryota = ../../user-config/ryota/home-manager/nixos.nix;
      # home-manager.users.rytswd = import ../../user-config/rytswd/home-manager;
    }
  ];
}
