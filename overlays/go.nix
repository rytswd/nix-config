final: prev:

# NOTE: Manual overlay to track a Go version that is newer than what nixpkgs
# currently ships (nixpkgs-unstable was on 1.26.3 while 1.26.4 was already
# released upstream). Patch releases are build-compatible, so overriding the
# version + source is enough.
#
# Version Update Steps:
#
# 1. Bump `version`
# 2. Get the new source hash:
#        nix-prefetch-url --type sha256 https://go.dev/dl/go<VERSION>.src.tar.gz
#    then convert to SRI:
#        nix hash convert --hash-algo sha256 --to sri <HASH>
# 3. Fill the hash in `src.hash`
#
# Remove this overlay once nixpkgs catches up.

{
  go = prev.go.overrideAttrs (old: {
    version = "1.26.4";
    src = prev.fetchurl {
      url = "https://go.dev/dl/go1.26.4.src.tar.gz";
      hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
    };
  });
}
