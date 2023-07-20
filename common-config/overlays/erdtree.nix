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
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "solidiquis";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Bn3gW8jfiX7tuANktAKO5ceokFtvURy2UZoL0+IBPaM=";
  };

  cargoHash = "sha256-Z3R8EmclmEditbGBb1Dd1hgGm34boCSI/fh3TBXxMG0=";

  meta = with lib; {
    description = "File-tree visualizer and disk usage analyzer";
    homepage = "https://github.com/solidiquis/erdtree";
    license = licenses.mit;
    maintainers = with maintainers; [ zendo ];
    mainProgram = "et";
  };
}
