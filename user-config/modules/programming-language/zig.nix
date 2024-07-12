{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.zig.enable = lib.mkEnableOption "Enable Zig development related tools.";
  };

  config = lib.mkIf config.programming-language.zig.enable {
    home.packages = [
      # pkgs.zig
      pkgs.zigpkgs.master # NOTE: Based on https://github.com/mitchellh/zig-overlay
      pkgs.zls
    ];
  };
}
