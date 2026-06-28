{
  pkgs,
  lib,
  inputs,
  overlays,
  ...
}:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
    overlays = overlays;
  };

  nix = {
    package = pkgs.nixVersions.stable;

    # Pin the `nixpkgs` flake-registry alias to THIS flake's pinned
    # `nixpkgs-unstable` input. With this, `nix shell nixpkgs#hello`,
    # `nix run nixpkgs#...` and `nix build nixpkgs#...` resolve to the exact
    # revision the system was built from -- not whatever
    # `github:NixOS/nixpkgs/nixpkgs-unstable` is at HEAD when the command
    # runs. Reproducible ad-hoc shells, no surprise version drift.
    #
    # Affects flake-style commands only. Legacy `<nixpkgs>` /
    # `nix-shell -p` / Nixd lookup go through `$NIX_PATH` instead -- see
    # the home-manager `programming/nix.nix` module for that side.
    # NixOS auto-registers `nixpkgs` (via `nixos/modules/misc/nixpkgs-flake.nix`)
    # to point at whatever `nixpkgs.lib.nixosSystem` was called with (here:
    # `inputs.nixpkgs`, the stable channel). The `flake = ...` shorthand
    # expands internally into a `to = { type = "path"; path = ...; }` tree,
    # so we have to `mkForce` the whole `nixpkgs` entry -- forcing just
    # `.flake` doesn't override the already-defined `.to.path`.
    registry.nixpkgs = lib.mkForce { flake = inputs.nixpkgs-unstable; };

    gc = {
      automatic = true;
      # interval = { Hour = 24; }; # NOTE: Does not exist on NixOS
      options = "--delete-older-than 7d";
    };
    settings = {
      # Optimise Nix Store using hard links to save storage space.
      auto-optimise-store = true;

      # Do not warn dirty Git repo.
      warn-dirty = false;

      # Recommended when using `direnv` etc.
      keep-derivations = true;
      keep-outputs = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      # Cache / Cachix
      trusted-users = [
        "@wheel"
        "root"
      ];

      # NOTE: When I have ~/.config/nix/nix.conf, that takes precedence for
      # setting the cache substituters. Make sure that I don't have any file
      # there.

      ###----------------------------------------
      ##   Caches
      #------------------------------------------
      # Layered model:
      #   * `substituters`              – baseline upstream caches, queried
      #                                   for every nix eval everywhere.
      #   * `extra-substituters`        – broadly useful, also queried
      #                                   every nix eval, no per-flake
      #                                   declaration needed.
      #   * `extra-trusted-substituters`– allow-list. Not queried by
      #                                   default. A flake can opt in via
      #                                   `nixConfig.extra-substituters`
      #                                   without prompting (because
      #                                   `accept-flake-config = true`).
      # See also `flake.nix#nixConfig` for the per-flake opt-ins.
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      extra-substituters = [
        # Numtide pull-through mirror of cache.nixos.org -- same NARs as
        # upstream (cache.nixos.org-1 key, no extra key needed), just kept
        # closer for lower latency / egress. Listed first so common nixpkgs
        # paths are fetched from here instead of the upstream CDN.
        "https://hetzner-cache.numtide.com"
        "https://cache.numtide.com"
        # Self-hosted binary cache (air/v0.1/binary-cache-niks3.org) -- reads
        # go straight to Cloudflare R2 behind this domain, so availability
        # never depends on the niks3 write-path server. Holds this flake's
        # own closures, which no community cache carries; see
        # docs/runbooks/binary-cache.org for the push side.
        "https://cache.re.dev"
        "https://cache.thalheim.io"
      ];
      extra-trusted-substituters = [
        "https://rytswd-nix-config.cachix.org"
        "https://swapdir.cachix.org"
        "https://ghostty.cachix.org"
        "https://niri.cachix.org"
        "https://cosmic.cachix.org"
        "https://hyprland.cachix.org"
        "https://roc-lang.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.re.dev-1:QdHy10XRVJsXFQeYMHuok7LAPNkq9Q0QUMCKQz6HURY="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
        "swapdir.cachix.org-1:AxK+CyOlKSBbZ/O2HhFz4V++zaIP1UqPaRenIbbFpUo="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "roc-lang.cachix.org-1:6lZeqLP9SadjmUbskJAvcdGR2T5ViR57pDVkxJQb8R4="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];

      # Accept flake-declared overrides (`nixConfig` in any flake) without
      # prompting. Safe because `extra-trusted-substituters` above acts as
      # the allow-list – only sanctioned caches actually get enabled.
      accept-flake-config = true;
    };
  };
}
