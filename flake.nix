{
  description = "NixOS and other Nix configurations for rytswd";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/release-24.05";
    };

    nixpkgs-unstable = {
      # url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      url = "github:NixOS/nixpkgs/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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

    roc = {
      url = "github:roc-lang/roc";
    };

    nixpkgs-zig-0-12.url = "github:vancluever/nixpkgs/vancluever-zig-0-12";

    zig = {
      url = "github:mitchellh/zig-overlay";
    };

    ghostty = {
      url = "git+ssh://git@github.com/mitchellh/ghostty";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprswitch.url = "github:h3rmt/hyprswitch/release";

    niri.url = "github:sodiboo/niri-flake";
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
    , nixpkgs-zig-0-12
    , zig
    , ghostty
    , ... } @ inputs:
    let mbp-arch = "aarch64";

    # + Overlays

    # emacsOverlay = emacs-overlay.overlays.default;
    # emacsOverlay = emacs-overlay.overlays.default (final : prev: {
	#   emacs29 = final.emacsGit.overrideAttrs (old : {
	#     name = "emacs29";
    #     version = "29.0-${emacs-29-src.shortRev}";
    #     src = emacs-29-src;
    #     withPgtk = true;
	#   });
	# });

    # Language specific overlays
    goOverlay = (final: prev: {
      go = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_22;
    });
    rustOverlay = rust-overlay.overlays.default;
    fenixOverlay = fenix.overlays.default;
    zigOverlay = zig.overlays.default;
    rocOverlay = (final: prev: {
      rocpkgs = inputs.roc.packages.${prev.system};
    });

    vscodeOverlay = (import ./overlays/vscode.nix);
    emacs-overlay = (import ./overlays/emacs.nix );
    tree-sitter-overlay = (import ./overlays/tree-sitter.nix );
    # erdtree-overlay = (import ./overlays/erdtree.nix );
    # yazi-overlay = (import ./overlays/yazi.nix );
    grip-overlay = (import ./overlays/grip.nix );

    overlays = [
      vscodeOverlay
      goOverlay
      rustOverlay
      zigOverlay
      # fenixOverlay
      rocOverlay

      emacs-overlay
      tree-sitter-overlay
      # erdtree-overlay
      # yazi-overlay
      grip-overlay
    ];

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
            # username = "ryota";
            overlays = overlays;
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
          asus-rog-zephyrus-g14-2024 = (import ./nixos-config/asus-rog-zephyrus-g14-2024 {
            inherit (nixpkgs) lib;
            inherit (nixpkgs-unstable.lib) nixosSystem;
            inherit nixpkgs nixpkgs-unstable home-manager ghostty;
            inherit (inputs) hyprland-plugins;
            inherit (inputs) hyprswitch;
            inherit (inputs) niri;
            system = "x86_64-linux";
            overlays = overlays;
          });
          mbp-2021-utm = (import ./nixos-config/mbp-utm {
            inherit (nixpkgs) lib;
            inherit (nixpkgs-unstable.lib) nixosSystem;
            inherit nixpkgs nixpkgs-unstable home-manager ghostty;
            system = "${mbp-arch}-linux";
            overlays = overlays;
          });
        };
      };
}
