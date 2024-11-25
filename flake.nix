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
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      # NOTE: Only used when I need to test the absolute latest.
      # url = "github:NixOS/nixpkgs/master";
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

    nix-config-private = {
      url = "git+ssh://git@github.com/rytswd/nix-config-private?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
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
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
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
    niri= {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-unstable";
    };

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
  let
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
    mirrordOverlay = (final: prev: {
      mirrord = prev.callPackage ./overlays/mirrord {};
    });

    tmpOverlay = (final: prev: {
      rofi-calc = prev.rofi-calc.override { rofi-unwrapped = prev.rofi-wayland-unwrapped; };
      # rofi-emoji = prev.rofi-emoji.override { };
    });

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
      # mirrordOverlay

      niriOverlay # TODO: Make this only for NixOS.
      # tmpOverlay
    ];

  in {
    ###----------------------------------------
    ##   macOS (Darwin) Configurations
    #------------------------------------------
    # The setup here will configure the macOS system for the given user.
    #
    # Firstly, it needs to adjust all the macOS specific settings, by
    # using the dedicated darwinConfigurations defined for each machine
    # setup. Most of the setup relies on `darwin.lib.darwinSystem`, but there
    # are other moving parts, and inheritance takes care of the required
    # params altogether.
    #
    # After configuring the macOS general settings, it will also load up
    # home-manager configurations of all the users referenced in the target
    # darwinConfiguration setup. The actual user configs are defined in
    # `./user-config/<username>/macos.nix`. Note that the user configuration
    # could be different from NixOS setup, and uses a separate file.
    darwinConfigurations = {
      ryota-mbp = (import ./macos-config/mbp {
        inherit nixpkgs nixpkgs-unstable darwin home-manager inputs overlays;
        system = "aarch64-darwin";
      });
    };

    ###----------------------------------------
    ##   NixOS Configurations
    #------------------------------------------
    # The setup here will configure the NixOS system for the given user.
    #
    # Firstly, it needs to adjust all the NixOS specific settings, by
    # using the dedicated nixosConfiguration defined for each machine
    # setup.
    #
    # After configuring the NixOS general settings, it will also load up
    # home-manager configurations of all the users referenced in the target
    # nixosConfiguration setup. The actual user configs are defined in
    # `./user-config/<username>/nixos.nix`. Note that the user configuration
    # could be different from macOS setup, and uses a separate file.
    #
    # Also, the home-manager config can be applied in a standalone setup,
    # allowing the day-to-day management to happen without requiring sudo.
    # This would produce older configs to be loaded upon restart, though.
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
    #
    # Note that, when using this standalone approach along with the above
    # NixOS / macOS configuration, the home-manager setup could be reverted
    # to the older version.
    homeConfigurations = {
      "ryota@asus-rog-zephyrus-g14-2024" = (import ./user-config/home-manager {
        inherit home-manager inputs overlays;
        pkgs = nixpkgs-unstable.legacyPackages."x86_64-linux";
        user-config = ./user-config/ryota/nixos.nix;
      });
    };
  };
}
