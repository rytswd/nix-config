{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.nix.enable = lib.mkEnableOption "Enable Nix development related tools.";
  };

  config = lib.mkIf config.programming.nix.enable {
    home.packages = [
      pkgs.nix-prefetch-github
      pkgs.nix-output-monitor
      pkgs.nvd
      pkgs.nh   # Friendly CLI wrapper
      pkgs.nixd # Language Server
    ];
    home.shellAliases = {
      flakeinit = "nix flake init -t \"github:rytswd/nix-direnv-template\" --refresh";
    };
  };
}
