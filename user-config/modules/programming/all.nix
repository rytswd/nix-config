{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.all.enable = lib.mkEnableOption "Enable programming related tooling that applies to any programming.";
  };

  config = lib.mkIf config.programming.all.enable {
    home.packages = [
      pkgs.tree-sitter # https://github.com/tree-sitter/tree-sitter
    ];
  };
}
