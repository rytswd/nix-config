{ pkgs, overlays, ... }:

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

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      extra-substituters = [
        "https://rytswd-nix-config.cachix.org"
        "https://ghostty.cachix.org"
        "https://niri.cachix.org"
        "https://cosmic.cachix.org"
        "https://hyprland.cachix.org"
        "https://roc-lang.cachix.org"
        "https://cache.numtide.com"
        "https://cache.thalheim.io"
      ];
      extra-trusted-public-keys = [
        "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "roc-lang.cachix.org-1:6lZeqLP9SadjmUbskJAvcdGR2T5ViR57pDVkxJQb8R4="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      ];
    };
  };
}
