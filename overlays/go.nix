final: prev:

# NOTE: Temporary overlay to track a Go release newer than what nixpkgs
# currently ships (nixpkgs-unstable is on 1.26.5 while 1.26.7 is out
# upstream, and we specifically need 1.26.7).
#
# Why base the override on `prev.go_1_26` and not `prev.go`: on the stable
# channel `prev.go` is 1.25.x and ships an OLD (1.22) bootstrap, but building
# Go 1.26 needs a >=1.24.6 bootstrap. `go_1_26` already uses the right
# bootstrap, so bumping its patch version is safe.
#
# Why there is no longer a patch override: the 1.26.4 pin had to swap out
# nixpkgs' `go_no_vendor_checks` patch, whose context predated the upstream
# `MainModules.GoVersion()` -> `loaderstate.MainModules.GoVersion(loaderstate)`
# refactor. nixpkgs has since moved to 1.26.5 and refreshed that patch, and it
# applies cleanly to the 1.26.7 source, so the locally-maintained copy
# (overlays/go-no-vendor-checks-1.26.4.patch) is dropped.
#
# Version Update Steps:
#
# 1. Bump `version`
# 2. Get the new source hash:
#        nix-prefetch-url --type sha256 https://go.dev/dl/go<VERSION>.src.tar.gz
#    then convert to SRI:
#        nix hash convert --hash-algo sha256 --to sri <HASH>
# 3. Fill the hash in `src.hash`
# 4. Re-build. If nixpkgs' `go_no_vendor_checks-1.26.patch` stops applying,
#    re-introduce the filter-and-replace shape (see git history for the 1.26.4
#    version of this file) with a patch refreshed against the new source.
#
# Remove this overlay once nixpkgs catches up.

{
  go = prev.go_1_26.overrideAttrs (_: {
    version = "1.26.7";
    src = prev.fetchurl {
      url = "https://go.dev/dl/go1.26.7.src.tar.gz";
      hash = "sha256-DtJOrHVRBQhbif6cq8J0K5GgrXuUtZ0602SRjryJVq0=";
    };
  });
}
