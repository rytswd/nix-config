{ home-manager
, pkgs
, inputs
, overlays
, user-config
, ...}:

home-manager.lib.homeManagerConfiguration rec {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs overlays; };
  modules = [
    # Adjust Nix and Nixpkgs related flags before proceeding.
    ./nix-flags.nix

    # # Manage system wide configurations here.
    # ./configuration.nix

    # # Create users.
    # ../../user-config/admin/create.nix
    # ../../user-config/ryota/create.nix
    # # ../../user-config/rytswd/create.nix

    # Set up home-manager and users.
    user-config
  ];
}
