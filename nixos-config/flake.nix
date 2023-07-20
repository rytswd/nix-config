{
    description = "Me testing";

    inputs = {
        nixpkgs = {
            url = "github:NixOS/nixpkgs/release-21.11";
        };

        nixpkgs-unstable = {
            url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        };

        home-manager = {
            url = "github:nix-community/home-manager/release-21.11";
        };

        # darwin = {
        #     url = "github:lnl7/nix-darwin/master";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };
    };

    outputs = { self, nixpkgs, home-manager, ... }@inputs: {
        # homeConfiguration."rytswd" = inputs.home-manager.lib.homeManagerConfiguration {
        #     configuration = import ./other/home-manager.nix;

        #     system = "aarch64-linux";
        #     username = "rytswd";
        #     homeDirecotry = "home/rytswd";
        #     stateVersion = "21.11";
        # };

        nixosConfigurations."mbp-2021-vm-nixos" = inputs.nixpkgs.lib.nixosSystem rec {
            system = "aarch64-linux";
            modules = [
                { nixpkgs.overlays = [
                    (final: prev: {
                        go = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.go_1_18;
                    })
                ];  
                }
                # Start with the hardware configuration around M1 VM first.
                ./modules/hardware/vm-aarch64.nix

                # Pull in any boot required configurations.
                ./modules/boot

                # Set up interface configurations.
                ./modules/interface/xserver.nix
                ./modules/interface/font.nix
                ./modules/interface/locale.nix

                # Set up system defaults.
                ./modules/system/packages.nix

                # Set up user details.
                ./modules/users/ryota
                ./modules/users/rytswd

                # Set up home-manager.
                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users."rytswd" = import ./modules/users/rytswd/home-manager.nix;
                }

                # Set up any last minute configurations.
            ];
        };

        darwinConfigurations."ryota-mbp" = inputs.darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [ ./configuration.nix ];
        };
        darwinPackages = self.darwinConfigurations."ryota-mbp".pkgs;
    };
}
