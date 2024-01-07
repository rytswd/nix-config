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
}
