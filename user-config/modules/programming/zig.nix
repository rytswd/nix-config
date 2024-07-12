{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.zig.enable = lib.mkEnableOption "Enable Zig development related tools.";
  };

  config = lib.mkIf config.programming.zig.enable {
    home.packages = [
      # pkgs.zig
      pkgs.zigpkgs.master # NOTE: Based on https://github.com/mitchellh/zig-overlay
      pkgs.zls
    ];
  };
}
