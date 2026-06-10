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
    # NOTE: Dedicated nixpkgs input that can be updated independently from the
    # main nixpkgs-unstable, for packages that need the latest version without
    # affecting everything else. Update with:
    #     nix flake update nixpkgs-unstable-fast-track
    nixpkgs-unstable-fast-track.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    srvos = {
      url = "github:nix-community/srvos";
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
    # Zig – zignix exposes `packages.<system>.zig-{master,0_16}` and
    # `lib.<system>.withName` so each version coexists on PATH under a
    # custom command name. Consumed directly from HM (no overlay).
    # See ./user-config/modules/programming/zig.nix.
    zignix = {
      url = "github:withre/zignix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zls.url = "github:zigtools/zls";

    # Roc
    roc = {
      url = "github:roc-lang/roc";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ###----------------------------------------
    ##  Tools
    #------------------------------------------
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

    # With own binary cache (and thus no nixpkgs following)
    ghostty.url = "github:ghostty-org/ghostty";
    llm-agents.url = "github:numtide/llm-agents.nix";
    noctalia.url = "github:noctalia-dev/noctalia-shell";

    librepods.url = "github:kavishdevar/librepods/linux/rust";

    # Personal ones
    swapdir.url = "git+ssh://git@github.com/rytswd/swapdir";
    # swapdir.url = "github:rytswd/swapdir";
    home-git-clone.url = "github:rytswd/home-git-clone";
    pi-agent-extensions.url = "github:rytswd/pi-agent-extensions/add-nix-module";
    skills.url = "github:rytswd/skills.nix";
    treesitter-grammars.url = "git+ssh://git@github.com/0-re/treesitter-grammars.nix";

    ###----------------------------------------
    ##  NixOS Specific
    #------------------------------------------
    # Disk partition handling
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    impermanence.url = "github:nix-community/impermanence";
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Window Manager
    niri.url = "github:sodiboo/niri-flake";
    hyprland.url = "github:hyprwm/Hyprland";
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

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # NOTE: With noctalia in place, awww isn't needed.
    awww.url = "git+https://codeberg.org/LGFae/awww";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      darwin,
      ...
    }@inputs:
    let
      # + Overlays
      # Language related overlays
      rocOverlay = (
        final: prev: {
          rocpkgs = inputs.roc.packages.${prev.stdenv.hostPlatform.system};
        }
      );

      # Editor related overlays
      # emacsOverlay = inputs.emacs-overlay.overlays.default;
      # vscodeOverlay = (import ./overlays/vscode.nix);

      # Other utility related overlays
      # gripOverlay = (import ./overlays/grip.nix );
      # erdtreeOverlay = (import ./overlays/erdtree.nix );
      # yaziOverlay = (import ./overlays/yazi.nix );

      overlays = [
        # rustOverlay
        # fenixOverlay
        rocOverlay
        # goOverlay -- intentionally NOT global. Consumed locally in
        # user-config/modules/programming/go.nix so only home-manager rebuilds
        # Go; the stable system closure is left untouched.

        # emacsOverlay
        # vscodeOverlay

        # gripOverlay
        # erdtreeOverlay
        # yaziOverlay
      ];
    in
    {
      ###----------------------------------------
      ##   Reusable modules
      #------------------------------------------
      # Each `flake-modules.nix` lives next to the modules it lists, so
      # adding/hiding a module is a single-line change in the relevant
      # tree -- not in flake.nix.
      nixosModules = import ./nixos-config/modules/flake-modules.nix;
      homeModules = import ./user-config/modules/flake-modules.nix;
      darwinModules = import ./macos-config/modules/flake-modules.nix;

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
        ryota-mbp-m1-max = (
          import ./macos-config/hosts/mbp-m1-max {
            inherit self nixpkgs nixpkgs-unstable
              inputs overlays home-manager darwin;
            system = "aarch64-darwin";
          }
        );
        ryota-mbp-m5-max = (
          import ./macos-config/hosts/mbp-m5-max {
            inherit self nixpkgs nixpkgs-unstable
              inputs overlays home-manager darwin;
            system = "aarch64-darwin";
          }
        );
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
        asus-rog-zephyrus-g14-2024 = (
          import ./nixos-config/asus-rog-zephyrus-g14-2024 {
            inherit self nixpkgs nixpkgs-unstable inputs overlays home-manager;
            system = "x86_64-linux";
          }
        );
        asus-rog-flow-z13-2025 = (
          import ./nixos-config/asus-rog-flow-z13-2025 {
            inherit self nixpkgs nixpkgs-unstable inputs overlays home-manager;
            system = "x86_64-linux";
          }
        );

        # Hetzner Cloud Kubernetes cluster (3× CX32, HA control-plane)
        hetzner-k8s-cp-1 = (
          import ./nixos-config/hetzner-k8s/cp-1 {
            inherit self nixpkgs nixpkgs-unstable inputs overlays;
            system = "x86_64-linux";
          }
        );
        hetzner-k8s-cp-2 = (
          import ./nixos-config/hetzner-k8s/cp-2 {
            inherit self nixpkgs nixpkgs-unstable inputs overlays;
            system = "x86_64-linux";
          }
        );
        hetzner-k8s-cp-3 = (
          import ./nixos-config/hetzner-k8s/cp-3 {
            inherit self nixpkgs nixpkgs-unstable inputs overlays;
            system = "x86_64-linux";
          }
        );

        # Apple Silicon UTM VM -- mirrors `asus-rog-flow-z13-2025` (same
        # shared module set, niri + hyprland + GNOME), minus disko /
        # impermanence / ZFS / asus-specific quirks.
        nixos-utm = (
          import ./nixos-config/mbp-utm {
            inherit self nixpkgs nixpkgs-unstable inputs overlays home-manager;
            system = "aarch64-linux";
          }
        );
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
      homeConfigurations =
        let
          # Build a standalone HM configuration for one (system, hostname,
          # profile) triple. `hostname` is plumbed via specialArgs so HM
          # modules that previously read `osConfig.networking.hostName`
          # (e.g. niri's per-host output.kdl) keep working standalone.
          # TODO: This looks too vevrbose, and covers too many cases that
          # will never be needed (e.g. x86 darwin), should be cleaned up.
          mkHome =
            system: hostname: profile:
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs-unstable {
                inherit system;
                overlays = overlays;
                config = {
                  allowUnfree = true;
                  allowUnsupportedSystem = true;
                };
              };
              extraSpecialArgs = {
                inherit
                  self
                  inputs
                  system
                  hostname
                  ;
              };
              modules = [ profile ];
            };
        in
        {
          # Linux laptops
          "ryota@asus-rog-zephyrus-g14-2024" =
            mkHome "x86_64-linux" "asus-rog-zephyrus-g14-2024"
              ./user-config/ryota/nixos.nix;
          "ryota@asus-rog-flow-z13-2025" =
            mkHome "x86_64-linux" "asus-rog-flow-z13-2025"
              ./user-config/ryota/nixos.nix;

          # Apple Silicon MBPs
          "ryota@mbp-m1-max" = mkHome "aarch64-darwin" "mbp-m1-max" ./user-config/ryota/macos.nix;
          "ryota@mbp-m5-max" = mkHome "aarch64-darwin" "mbp-m5-max" ./user-config/ryota/macos.nix;

          # Coder / devspace workspaces — two arch variants. `hostname`
          # isn't host-specific here; "coder" is a placeholder used by HM
          # modules that gracefully fall back when no per-host data exists.
          "ryota@coder" = mkHome "x86_64-linux" "coder" ./user-config/ryota/coder.nix;
          "ryota@coder-aarch64" = mkHome "aarch64-linux" "coder" ./user-config/ryota/coder.nix;
        };

      ###----------------------------------------
      ##   Custom ISO
      #------------------------------------------
      # The below sets up two paths for building NixOS image:
      #
      #     nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage
      #
      # And much easier short hand of
      #
      #     nix build .#installer-iso
      #
      # After creating the image, this can be flashed to USB disk by command like:
      #
      #     sudo dd if=result/iso/nixos-rytswd-26.05-x86_64-linux.iso of=/dev/sdX bs=4M status=progress oflag=sync
      nixosConfigurations.installer-iso = (
        import ./nixos-config/iso {
          inherit
            self
            nixpkgs
            nixpkgs-unstable
            home-manager
            inputs
            overlays
            ;
          system = "x86_64-linux";
        }
      );
      packages.x86_64-linux.installer-iso =
        self.nixosConfigurations.installer-iso.config.system.build.isoImage;

      ###----------------------------------------
      ##   Checks (CI-friendly per-host derivations)
      #------------------------------------------
      # Logic lives in ./checks.nix to keep this file readable. See that
      # file's header for the full rationale, system list, and blacklist.
      checks = import ./checks.nix {
        inherit self;
        lib = nixpkgs.lib;
      };

      ###----------------------------------------
      ##   Flake apps
      #------------------------------------------
      # `hm`        -- standalone Home Manager dispatcher (host/arch -> profile).
      # `bootstrap` -- one-shot coder/devspace setup (also `default`), so a
      #                fresh workspace comes up with a single command:
      #
      #                    nix run github:rytswd/nix-config
      #
      # aarch64-linux is included so aarch64 coder workspaces can bootstrap.
      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          bootstrap = import ./apps/bootstrap { inherit pkgs self; };
        in
        {
          hm = import ./apps/hm { inherit pkgs; };
          inherit bootstrap;
          default = bootstrap;
        }
      );
    };

  # Per-flake substituters -- only queried while this flake is in scope.
  # Must be a literal attrset of literal lists here -- Nix's flake metadata
  # parser rejects `import` / `inherit (import ...) ...` / `let`. See
  # `nixos-config/modules/nix-base.nix` for the layered cache model.
  nixConfig = {
    extra-substituters = [
      "https://rytswd-nix-config.cachix.org"
      "https://ghostty.cachix.org"
      "https://niri.cachix.org"
      "https://cosmic.cachix.org"
      "https://hyprland.cachix.org"
      "https://roc-lang.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "roc-lang.cachix.org-1:6lZeqLP9SadjmUbskJAvcdGR2T5ViR57pDVkxJQb8R4="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
