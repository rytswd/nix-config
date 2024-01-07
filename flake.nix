{
  description = "NixOS and other Nix configurations for rytswd";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/release-23.11";
    };

    nixpkgs-unstable = {
      # url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      url = "github:NixOS/nixpkgs/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # emacs-29-src = {
    #   url = "github:emacs-mirror/emacs/emacs-29";
    #   flake = false;
    # };
    # emacs-overaly = {
    #   url = "github:Nix-Community/emacs-overlay";
    # };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ghostty = {
      url = "git+ssh://git@github.com/mitchellh/ghostty";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , darwin
    # , emacs-29-src
    # , emacs-overlay
    , rust-overlay
    , fenix
    , ghostty
    , ... }:
    let mbp-arch = "aarch64";

        # + Overlays
        # Go -- prefer the latest version
        goOverlay = (final: prev: {
          go = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_21;
        });
        vscodeOverlay = import ./common-config/overlays/vscode.nix;

        # emacsOverlay = emacs-overlay.overlays.default;
        # emacsOverlay = emacs-overlay.overlays.default (final : prev: {
	      #   emacs29 = final.emacsGit.overrideAttrs (old : {
	      #     name = "emacs29";
        #     version = "29.0-${emacs-29-src.shortRev}";
        #     src = emacs-29-src;
        #     withPgtk = true;
	      #   });
	      # });
        
        rustOverlay = rust-overlay.overlays.default;
        fenixOverlay = fenix.overlays.default;

        emacs-overlay = (import ./common-config/overlays/emacs.nix );
        tree-sitter-overlay = (import ./common-config/overlays/tree-sitter.nix );
        yazi-overlay = (import ./common-config/overlays/yazi.nix );
    in {
      # ====
      # macOS (Darwin) Configurations
      #
      # The setup here will configure the macOS system for the given user.
      #
      # Firstly, it needs to adjust all the macOS specific settings, by
      # using the dedicated darwinConfigurations defined for each machine
      # setup. We only need access to `darwin.lib.darwinSystem`, and thus
      # inheriting it specifically.
      #
      # After configuring the macOS general settings, it will also load up
      # home-manager configurations of the given user (which is defined by
      # `username`). The actual code to load up the home-manager configs
      # is defined in `./user-config/<username>/home-manager.nix`.
      darwinConfigurations = {
        ryota-mbp = (import ./macos-config/mbp {
          inherit (nixpkgs) lib;
          inherit (darwin.lib) darwinSystem;
          inherit nixpkgs nixpkgs-unstable home-manager ghostty;
          system = "${mbp-arch}-darwin";
          username = "ryota";
          overlays = [
            vscodeOverlay
            goOverlay
            rustOverlay
            # fenixOverlay

            emacs-overlay
            tree-sitter-overlay
            yazi-overlay
          ];
        });
        ryota-test-mbp = (import ./macos-config/mbp {
          inherit (nixpkgs) lib;
          inherit (darwin.lib) darwinSystem;
          inherit nixpkgs nixpkgs-unstable home-manager rust-overlay;
          system = "${mbp-arch}-darwin";
          username = "ryota-test";
        });
      };

      # ====
      # NixOS Configurations
      #
      # The setup here will configure the macOS system for the given user.
      #
      # Firstly, it needs to adjust all the NixOS specific settings, by
      # using the dedicated nixosConfiguration defined for each machine
      # setup. This also relies on any virtualisation settings, and thus
      # the directory structure allows additional directories to be
      # created for any special use cases.
      #
      # After configuring the NixOS general settings, it will also load up
      # home-manager configurations of the given user (which is defined by
      # `username`). The actual code to load up the home-manager configs
      # is defined in `./user-config/<username>/home-manager.nix`.
      nixosConfigurations = {
        rytswd-mbp-2021-vmware = (import ./nixos-config/mbp-vmware {
          inherit (nixpkgs) lib;
          inherit nixpkgs nixpkgs-unstable home-manager rust-overlay;
          system = "${mbp-arch}-darwin";
          username = "rytswd";
        });
      };

      # TODO This is working -- only for testing, remove this
      x = nixpkgs.legacyPackages."${mbp-arch}-darwin".mkShellNoCC {
        shellHook = ''
                echo "Hello, world!"
            '';
        packages = with nixpkgs.legacyPackages."${mbp-arch}-darwin"; [
          neofetch
        ];
      };

      # TODO Remove below as above should be able to take over.
      nixosConfigurations."mbp-2021-vm-nixos" = nixpkgs.lib.nixosSystem rec {
        system = "${mbp-arch}-linux";
        modules = [
          { nixpkgs.overlays = [
              (final: prev: {
                go = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_19;
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
    };
}
