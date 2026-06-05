{ self
, nixpkgs
, nixpkgs-unstable
, darwin
, home-manager
, system
, overlays
, inputs
, ...
}:

darwin.lib.darwinSystem {
  inherit system;
  specialArgs = {
    inherit self nixpkgs nixpkgs-unstable home-manager overlays inputs;
  };
  modules = [
    "${self}/macos-config/profiles/common.nix"

    ###----------------------------------------
    ##   Per-host identity
    #------------------------------------------
    {
      networking.hostName      = "ryota-mbp-m1-max";
      networking.localHostName = "ryota-mbp-m1-max";
      networking.computerName  = "Ryota's MBP M1 Max";
    }
  ];
}
