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
      allowUnsupportedSystem = true;
    };
    overlays = overlays;
  };

  ###----------------------------------------
  ##  Host identity
  #------------------------------------------
  networking.hostName      = "ryota-mbp-m5-max";
  networking.localHostName = "ryota-mbp-m5-max";
  networking.computerName  = "Ryota's MBP M5 Max";

  ###----------------------------------------
  ##  System defaults
  #------------------------------------------
  system.primaryUser = "ryota";

  system.stateVersion = 4;
}
