# Nix daemon settings for darwin hosts.
#
# Mirrors the shape of `nixos-config/modules/nix-base.nix` so the two
# sides of the repo stay legible. Differences are darwin-specific
# (NixOS-only options like `registry.nixpkgs` and Linux-only caches
# are intentionally absent here).
{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.stable;

    gc = {
      automatic = true;
      interval = { Hour = 23; };
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;

    settings = {
      warn-dirty = false;

      # Recommended when using `direnv` etc.
      keep-derivations = true;
      keep-outputs = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      trusted-users = [
        "@admin"
        "root"
      ];

      ###----------------------------------------
      ##   Caches
      #------------------------------------------
      # Same layered model as the NixOS side. See
      # `nixos-config/modules/nix-base.nix` for the full explanation.
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      extra-substituters = [
        "https://cache.numtide.com"
        "https://cache.thalheim.io"
      ];
      extra-trusted-substituters = [
        "https://rytswd-nix-config.cachix.org"
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];

      accept-flake-config = true;
    };
  };
}
