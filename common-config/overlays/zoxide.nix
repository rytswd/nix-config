final: prev:

{
  zoxide = prev.zoxide.overrideAttrs (old: rec {
    version = "0.10.0-latest"; # Created for my own use case

    src = prev.fetchFromGitHub {
      owner = "ajeetdsouza";
      repo = "zoxide";
      rev = "3022cf3686b85288e6fbecb2bd23ad113fd83f3b";
      sha256 = "sha256-ut+/F7cQ5Xamb7T45a78i0mjqnNG9/73jPNaDLxzAx8=";
    };
  });

  # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
  # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/6
  cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
    name = "zoxide-vendor.tar.gz";
    inherit src;
    outputHash = ""; # Update this with cargoHash
  });

}
