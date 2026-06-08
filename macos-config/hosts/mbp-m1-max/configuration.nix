{ self
, overlays
, ...
}:

{
  imports = [
    "${self}/macos-config/modules/nix-base.nix"
    "${self}/macos-config/modules/homebrew.nix"
    "${self}/macos-config/modules/security.nix"

    # Per-cask opt-ins go here. Default: none, MBP stays minimal.
    # Examples (uncomment to enable):
    # "${self}/macos-config/modules/utility/orbstack.nix"
    # "${self}/macos-config/modules/browser/zen.nix"
    # "${self}/macos-config/modules/product/collaboration/signal.nix"
  ];

  ###----------------------------------------
  ##  nixpkgs config
  #------------------------------------------
  nixpkgs = {
    config = {
      allowUnfree = true;
      # Introduced for fcitx which historically lacked Darwin support;
      # keep enabled until verified obsolete.
      allowUnsupportedSystem = true;
    };
    overlays = overlays;
  };

  ###----------------------------------------
  ##  Host identity
  #------------------------------------------
  networking.hostName      = "ryota-mbp-m1-max";
  networking.localHostName = "ryota-mbp-m1-max";
  networking.computerName  = "Ryota's MBP M1 Max";

  ###----------------------------------------
  ##  System defaults
  #------------------------------------------
  system.primaryUser = "ryota";

  # nix-darwin state version. Bump only when migrating to a new
  # nix-darwin major -- see release notes.
  system.stateVersion = 4;
}
