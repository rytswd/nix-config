{ lib
, nixpkgs
, nixpkgs-unstable
, darwinSystem
, home-manager
, system
, overlays
, inputs
, ...}:

darwinSystem {
  inherit system;
  # inputs = { inherit username; };
  specialArgs = { inherit lib nixpkgs nixpkgs-unstable home-manager overlays; };
  modules = [
    # Adjust Nix and Nixpkgs related flags before proceeding.
    # ./nix-flags.nix
    # TODO: This is the setup used in NixOS. Ensure to do the same here for
    # macOS rather than doing the manual setup below.
    # Ensure to allow unfree packages first, such as VSCode, Zoom, etc.
    {
      nixpkgs = {
        config = {
          allowUnfree = true;
          # This is introduced for fcitx which did not have the Darwin support.
          allowUnsupportedSystem = true;
        };

        overlays = overlays;
      };
    }

    # Manage system wide configurations here.
    ./configuration.nix

    # Create users.
    ../../user-config/ryota/create.nix
    # ../../user-config/rytswd/create.nix

    # Set up home-manager and users.
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };  # Pass flake variable

      # Each user needs to be set up separately. Because home-manager needs to
      # know where the home directory is, I need to specify the username again.
      home-manager.users.ryota = import ../../user-config/ryota/macos.nix;
    }
  ];
}
