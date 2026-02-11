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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # NOTE: Only used when I need to test the absolute latest. This would mean
    # I wouldn't be able to use the binary cache.
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # NOTE: For any flake reference that should use dedicated binary cache,
    # I should not update the nixpkgs input. When I want to get the latest
    # binary, I should update it with "nixpkgs-unstable" or master.

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # Use latest unstable for home-manager.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      # Use latest unstable for macOS.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      # url = "github:rytswd/sops-nix/add-yubikey-age-support";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-config-private = {
      url = "git+ssh://git@github.com/rytswd/nix-config-private?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.sops-nix.follows = "sops-nix";
    };

    ###----------------------------------------
    ##  Language related flakes
    #------------------------------------------
    # Roc
    roc = {
      url = "github:roc-lang/roc";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Zig
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls = {
      url = "github:zigtools/zls";
      inputs.zig-overlay.follows = "zig-overlay";
    };

    ###----------------------------------------
    ##  Tools
    #------------------------------------------
    ghostty = {
      url = "github:ghostty-org/ghostty";
      # inputs.nixpkgs-stable.follows = "nixpkgs-unstable";
      # inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs-mirror-30-src = {
      url = "github:emacs-mirror/emacs/emacs-30";
      flake = false;
    };
    emacs-mirror-latest-src = {
      url = "github:emacs-mirror/emacs";
      flake = false;
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
    swapdir.url = "git+ssh://git@github.com/rytswd/swapdir";
    # swapdir.url = "github:rytswd/swapdir";
    home-git-clone.url = "github:rytswd/home-git-clone";
    treesitter-grammars.url = "git+ssh://git@github.com/0-re/treesitter-grammars.nix";
    pi-agent-extensions.url = "github:rytswd/pi-agent-extensions/add-nix-module";

    ###----------------------------------------
    ##  NixOS Specific
    #------------------------------------------
    # Disk partition handling
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ephemeral root
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    # Window Manager
    niri= {
      url = "github:sodiboo/niri-flake";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
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
    zigOverlay = inputs.zig-overlay.overlays.default;
    rocOverlay = (final: prev: {
      rocpkgs = inputs.roc.packages.${prev.stdenv.hostPlatform.system};
    });

    # Editor related overlays
    # emacsOverlay = inputs.emacs-overlay.overlays.default;
    # vscodeOverlay = (import ./overlays/vscode.nix);

    # Other utility related overlays
    treesitterOverlay = inputs.treesitter-grammars.overlays.default;
    treeSitterOverlay = (import ./overlays/tree-sitter.nix );
    # gripOverlay = (import ./overlays/grip.nix );
    # erdtreeOverlay = (import ./overlays/erdtree.nix );
    # yaziOverlay = (import ./overlays/yazi.nix );

    overlays = [
      # rustOverlay
      # fenixOverlay
      zigOverlay
      rocOverlay

      # emacsOverlay
      # vscodeOverlay

      # TODO: merge into one. treesitter is coming from flake, treeSitter is local.
      # treeSitterOverlay
      # treesitterOverlay

      # gripOverlay
      # erdtreeOverlay
      # yaziOverlay
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
      asus-rog-flow-z13-2025 = (import ./nixos-config/asus-rog-flow-z13-2025 {
        inherit nixpkgs nixpkgs-unstable home-manager inputs overlays;
        system = "x86_64-linux";
      });
      installer-iso = (import ./nixos-config/iso {
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
