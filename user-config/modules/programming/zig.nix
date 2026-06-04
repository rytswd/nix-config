{ pkgs, inputs, ... }:
# Zig is supplied by https://github.com/withre/zignix. We pull two
# versions and rename them with `withName` so they coexist on PATH:
#
#   zig       → latest master nightly
#   zig-0.16  → latest 0.16 release
#
# zls is older than zig master but tracks tagged Zig releases.
let
  system  = pkgs.stdenv.hostPlatform.system;
  zignix  = inputs.zignix.lib.${system};
  pkgsFor = inputs.zignix.packages.${system};
in
{
  home.packages = [
    (zignix.withName "zig"      pkgsFor.zig-master)
    (zignix.withName "zig-0.16" pkgsFor.zig-0_16)
    pkgs.zls
  ];
}
