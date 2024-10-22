# NOTE: When I have an error message such as:
#
#     error: failed to open archive: Failed to open '/nix/store/1fry2dwlb5mdq6gy51bs2axd6ipgvr0d-source'
#
# This is likely caused by corrupted or missing store path. I can get this
# sorted with the following command:
#
#     nix-store --verify --repair
#
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
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # nh command support for macOS
    nh-darwin.url = "github:ToyVo/nh_darwin";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ###----------------------------------------
    ##  Language related flakes
    #------------------------------------------
    # Rust -- TODO: check whether I should use fenix or rust-overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Roc
    roc = {
      url = "github:roc-lang/roc";
    };

    # Zig
    # nixpkgs-zig-0-12.url = "github:vancluever/nixpkgs/vancluever-zig-0-12";
    zig.url = "github:mitchellh/zig-overlay";

    ###----------------------------------------
    ##  Tools
    #------------------------------------------
    ghostty = {
      url = "git+ssh://git@github.com/mitchellh/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs-unstable";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    jujutsu.url = "github:martinvonz/jj";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs-30-src = {
      url = "github:emacs-mirror/emacs/emacs-30";
      flake = false;
    };

    ###----------------------------------------
    ##  NixOS Specific
    #------------------------------------------
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Window Manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    hyprscroller = {
      url = "github:dawsers/hyprscroller";
      inputs.hyprland.follows = "hyprland";
    };

    niri= {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-unstable";
    };

    # Desktop Environment
    # cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   inputs.nixpkgs-stable.follows = "nixpkgs";
    # };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , darwin
    , ... } @ inputs:
    let mbp-arch = "aarch64";

    # + Overlays

    # Language related overlays
    goOverlay = (final: prev: {
      go = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_23;
    });
    rustOverlay = inputs.rust-overlay.overlays.default;
    fenixOverlay = inputs.fenix.overlays.default;
    zigOverlay = inputs.zig.overlays.default;
    rocOverlay = (final: prev: {
      rocpkgs = inputs.roc.packages.${prev.system};
    });

    # Editor related overlays
    emacsOverlay = inputs.emacs-overlay.overlays.default;
    # emacsOverlayPersonal = (import ./overlays/emacs.nix ); # FIXME: Move to module
    vscodeOverlay = (import ./overlays/vscode.nix);

    # Other utility related overlays
    jujutsuOverlay = inputs.jujutsu.overlays.default;
    treeSitterOverlay = (import ./overlays/tree-sitter.nix );
    # erdtreeOverlay = (import ./overlays/erdtree.nix );
    # yaziOverlay = (import ./overlays/yazi.nix );
    gripOverlay = (import ./overlays/grip.nix );

    # NixOS related overlays
    niriOverlay = inputs.niri.overlays.niri;
    overlays = [
      goOverlay
      rustOverlay
      zigOverlay
      # fenixOverlay
      rocOverlay

      emacsOverlay
      # emacsOverlayPersonal
      vscodeOverlay

      jujutsuOverlay
      treeSitterOverlay
      # erdtreeOverlay
      # yaziOverlay
      gripOverlay

      niriOverlay # TODO: Make this only for NixOS.
    ];

      in {
        ###----------------------------------------
        ##   macOS (Darwin) Configurations
        #------------------------------------------
        # The setup here will configure the macOS system for the given user.
        #
        # Firstly, it needs to adjust all the macOS specific settings, by
        # using the dedicated darwinConfigurations defined for each machine
        # setup. We only need access to `darwin.lib.darwinSystem`, and thus
        # inheriting it specifically.
        #
        # After configuring the macOS general settings, it will also load up
        # home-manager configurations of all the users referenced in the target
        # darwinConfiguration setup. The actual user configs are defined in
        # `./user-config/<username>/macos.nix`.
        darwinConfigurations = {
          ryota-mbp = (import ./macos-config/mbp {
            inherit nixpkgs nixpkgs-unstable darwin home-manager inputs overlays;
            system = "${mbp-arch}-darwin";
          });
        };

        ###----------------------------------------
        ##   NixOS Configurations
        #------------------------------------------
        # The setup here will configure the NixOS system for the given user.
        #
        # Firstly, it needs to adjust all the NixOS specific settings, by
        # using the dedicated nixosConfiguration defined for each machine
        # setup. This also relies on any virtualisation settings, and thus
        # the directory structure allows additional directories to be
        # created for any special use cases.
        #
        # After configuring the NixOS general settings, it will also load up
        # home-manager configurations of all the users referenced in the target
        # nixosConfiguration setup. The actual user configs are defined in
        # `./user-config/<username>/macos.nix`.
        nixosConfigurations = {
          asus-rog-zephyrus-g14-2024 = (import ./nixos-config/asus-rog-zephyrus-g14-2024 {
            inherit nixpkgs nixpkgs-unstable home-manager inputs overlays;
            system = "x86_64-linux";
          });
          # TODO: Fix this based on the new setup.
          # mbp-2021-utm = (import ./nixos-config/mbp-utm {
          #   inherit (nixpkgs-unstable) lib;
          #   inherit (nixpkgs-unstable.lib) nixosSystem;
          #   inherit nixpkgs nixpkgs-unstable home-manager inputs overlays;
          #   system = "${mbp-arch}-linux";
          # });
        };

        ###----------------------------------------
        ##   Home Manager Configuration
        #------------------------------------------
        # While I could add home-manager embedded within each system (NixOS /
        # macOS), it just makes it clear to have user configuration separated
        # from the machine configuration. It also means when I need to update
        # user settings, I wouldn't have to run with sudo.
        homeConfigurations = {
          "ryota@asus-rog-zephyrus-g14-2024" = (import ./user-config/home-manager {
            inherit home-manager inputs overlays;
            pkgs = nixpkgs-unstable.legacyPackages."x86_64-linux";
            user-config = ./user-config/ryota/nixos.nix;
          });
        };
      };
}
