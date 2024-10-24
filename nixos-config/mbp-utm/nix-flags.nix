{ pkgs
, overlays
, ...}:

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

    # configureBuildUsers = true; # NOTE: Does not exist for NixOS

    gc = {
      automatic = true;
      # interval = { Hour = 24; }; # NOTE: Does not exist on NixOS
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [ "@admin" ];

      auto-optimise-store = true;
      # Recommended when using `direnv` etc.
      keep-derivations = true;
      keep-outputs = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://rytswd-nix-config.cachix.org"
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="

        # Unused
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        # "emacs-osx.cachix.org-1:Q2++pOcNsiEjmDLufCzzdquwktG3fFDYzZrd8cEj5Aw="
      ];
    };
  };
}
