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
    ./configuration.nix

    ../../user-config/ryota/create.nix
    # ../../user-config/rytswd/create.nix
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };  # Pass flake variable

      home-manager.users.ryota = import ../../user-config/ryota/home-manager/macos.nix;
      # home-manager.users.rytswd = import ../../user-config/rytswd/home-manager;
    }
  ];
}
