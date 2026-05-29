{ pkgs, ... }:
{
  home.packages =
    let
      # NOTE: Based on https://github.com/mitchellh/zig-overlay
      zig = pkgs.zigpkgs.master;
      # zls = inputs.zls.packages.${pkgs.stdenv.hostPlatform.system}.zls.overrideAttrs (_: {
      #   nativeBuildInputs = [ zig ];
      # });
      zls = pkgs.zls; # NOTE: This is older than zig itself.
    in
    [
      # pkgs.zig
      zig
      zls
    ];
}
