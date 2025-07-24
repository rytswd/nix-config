{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    programming.zig.enable = lib.mkEnableOption "Enable Zig development related tools.";
  };

  config = lib.mkIf config.programming.zig.enable {
    home.packages = let
      # NOTE: Based on https://github.com/mitchellh/zig-overlay
      zig = pkgs.zigpkgs.master;
      zls = inputs.zls.packages.${pkgs.system}.zls.overrideAttrs (_: {
        nativeBuildInputs = [ zig ];
      });
    in [
      # pkgs.zig
      zig
      zls
    ];
  };
}
