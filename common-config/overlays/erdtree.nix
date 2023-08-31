{ lib, rustPlatform, fetchFromGitHub, ... }:

# NOTE: This is a manual overlay setup.
#
# Version Update Steps:
#
# 1. Update version in `version`
# 2. Remove hash in `src.hash` and `cargoHash` (not remove the key, just the value)
# 3. Build and get the error message containing the hash
# 4. Fill the hash in `src.hash`
# 5. Build again and get the error message containing the hash
# 6. Fill the hash in `cargoHash`
#

rustPlatform.buildRustPackage rec {
  pname = "erdtree";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "solidiquis";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-rm3j1exvdlJtMXgFeRmzr3YU/sLpQFL3PCa8kLVlinM=";
  };

  cargoHash = "sha256-rHrdGL/2diBwsWJyg7gaa6UmcUdvGhUPhLNESSBvDDg=";

  meta = with lib; {
    description = "File-tree visualizer and disk usage analyzer";
    homepage = "https://github.com/solidiquis/erdtree";
    license = licenses.mit;
    maintainers = with maintainers; [ zendo ];
    mainProgram = "erd";
  };
}
