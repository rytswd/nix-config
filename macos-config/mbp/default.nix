{ lib, nixpkgs, nixpkgs-unstable, home-manager, darwinSystem, overlays, username, system, ...}:

darwinSystem {
  inherit system;
  inputs = { inherit username; };
  specialArgs = { inherit lib nixpkgs nixpkgs-unstable home-manager username; };
  modules = [
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
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit username; };  # Pass flake variable
      home-manager.users.${username} = import ../../user-config/${username}/home-manager.nix;
    }
  ];
}
