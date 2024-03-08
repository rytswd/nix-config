final: prev:

# NOTE: This is a manual overlay setup.
# Ref: https://github.com/solidiquis/erdtree
#
# Version Update Steps:
#
# 1. Update version in `version`
# 2. Remove hash in `src.hash` and `cargoHash` (do not remove the key, just the value)
# 3. Build and get the error message containing the hash
# 4. Fill the hash in `src.hash`
# 5. Build again and get the error message containing the hash for Cargo
# 6. Fill the hash in `cargoHash`

{
  erdtree = prev.erdtree.overrideAttrs (old: rec {
    pname = "erdtree";
    version = "3.1.2";

    src = prev.fetchFromGitHub {
      owner = "solidiquis";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-rm3j1exvdlJtMXgFeRmzr3YU/sLpQFL3PCa8kLVlinM=";
    };

    cargoHash = "sha256-rHrdGL/2diBwsWJyg7gaa6UmcUdvGhUPhLNESSBvDDg=";
  });
}
