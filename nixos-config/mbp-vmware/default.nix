{ lib, nixpkgs, nixpkgs-unstable, home-manager, username, system, ...}:


nixpkgs.lib.nixosSystem rec {
  inherit system;
  specialArgs = { inherit lib nixpkgs nixpkgs-unstable home-manager username; };
  modules = [
    { nixpkgs.overlays = [
        (final: prev: {
          go = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_19;
        })
      ];
    }
    # Start with the hardware configuration around M1 VM first.
    ../modules/hardware/vm-aarch64.nix

    # Pull in any boot required configurations.
    ../modules/boot

    # Set up interface configurations.
    ../modules/interface/xserver.nix
    ../modules/interface/font.nix
    ../modules/interface/locale.nix

    # Set up system defaults.
    ../modules/system/packages.nix

    # Set up user details.
    ../modules/user/ryota
    ../modules/user/rytswd

    # Set up home-manager.
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${username}" = import ../../user-config/ryota/home-manager.nix {
        inherit username;
        pkgs = nixpkgs-unstable;
        config = nixpkgs-unstable.config;
      };
    }


    # Set up any last minute configurations.
  ];
}
