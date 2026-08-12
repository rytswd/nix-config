# Keep nushell on the channel home-manager is pinned to, machine-wide.
#
# HM always instantiates against nixpkgs-unstable (shared/home-manager.nix)
# and writes config.nu -- including unstable fzf's integration script -- for
# *its* nushell. On the stable hosts the login shell came from the system
# channel instead, so 26.05's 0.112.2 had to parse a config using fzf
# 0.74.2's `str lowercase`, new in 0.114.0, and every terminal opened with a
# parse error. Stating the rule once here beats pinning fzf back, or hiding
# the channel choice at each `pkgs.nushell` use site.
#
# `nushellPlugins` follows: plugins are version-locked to the host binary.
nixpkgs-unstable: final: prev:

let
  # Already unstable (darwin, unstable hosts, every HM pkgs) -- skip, so
  # those evals don't pay for a second nixpkgs giving the identical path.
  isUnstable = prev.path == nixpkgs-unstable.outPath;

  pkgs-unstable = import nixpkgs-unstable {
    inherit (prev.stdenv.hostPlatform) system;
  };
in
prev.lib.optionalAttrs (!isUnstable) {
  inherit (pkgs-unstable) nushell nushellPlugins;
}
