final: prev:

# NOTE: Temporary overlay to track a Go release newer than what the locked
# nixpkgs-unstable ships: it only has `go_1_27` at 1.27rc2, while we need
# 1.27.1. nixpkgs itself is already on 1.27.1 (`go_1_27` / `go_latest`), so
# this goes away with the next nixpkgs-unstable bump.
#
# Why base the override on `prev.go_1_27` and not `prev.go`: `prev.go` is
# still the 1.26 line, while `go_1_27` already carries the bootstrap and
# patches for 1.27. nixpkgs' 1.27.nix differs between 1.27rc2 and 1.27.1 only
# in version and hash, and its patch files are identical, so bumping just the
# version is safe.
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
  go = prev.go_1_27.overrideAttrs (_: {
    version = "1.27.1";
    src = prev.fetchurl {
      url = "https://go.dev/dl/go1.27.1.src.tar.gz";
      hash = "sha256-TkCKuuEm2Ra2FkYnGT8sVPDjyhMS1pO4bbRfhiqyOLE=";
    };
  });
}
