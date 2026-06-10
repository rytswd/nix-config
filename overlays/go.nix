final: prev:

# NOTE: Manual overlay to track a Go version that is newer than what nixpkgs
# currently ships (nixpkgs-unstable was on 1.26.3 while 1.26.4 was already
# released upstream).
#
# Two gotchas handled here:
#
# 1. Bootstrap: we base the override on `prev.go_1_26` (not `prev.go`). On the
#    stable channel `prev.go` is 1.25.x and ships an OLD (1.22) bootstrap, but
#    building Go 1.26 needs a >=1.24.6 bootstrap. `go_1_26` already uses the
#    right bootstrap, so bumping its patch version is safe.
#
# 2. Patch: nixpkgs applies a `go_no_vendor_checks` patch whose context no
#    longer matches because upstream refactored `MainModules.GoVersion()` ->
#    `loaderstate.MainModules.GoVersion(loaderstate)` between 1.26.3 and
#    1.26.4. So we swap that one patch for a locally-maintained copy that
#    matches the 1.26.4 source.
#
# Version Update Steps:
#
# 1. Bump `version`
# 2. Get the new source hash:
#        nix-prefetch-url --type sha256 https://go.dev/dl/go<VERSION>.src.tar.gz
#    then convert to SRI:
#        nix hash convert --hash-algo sha256 --to sri <HASH>
# 3. Fill the hash in `src.hash`
# 4. Re-build. If the no-vendor-checks patch fails again, refresh
#    ./go-no-vendor-checks-<VERSION>.patch against the new source.
#
# Remove this overlay (and the patch file) once nixpkgs catches up.

{
  go = prev.go_1_26.overrideAttrs (old: {
    version = "1.26.4";
    src = prev.fetchurl {
      url = "https://go.dev/dl/go1.26.4.src.tar.gz";
      hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
    };

    # Replace the upstream-incompatible no-vendor-checks patch with a refreshed
    # one, keeping every other nixpkgs patch untouched.
    patches =
      (builtins.filter (
        p: !(prev.lib.hasInfix "go_no_vendor_checks" (toString p))
      ) old.patches)
      ++ [ ./go-no-vendor-checks-1.26.4.patch ];
  });
}
