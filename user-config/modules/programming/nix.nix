{ pkgs
, lib
, config
, inputs
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
      pkgs.nixpkgs-review # PR review utility
    ];
    home.shellAliases = {
      flakeinit = "nix flake init -t \"github:rytswd/nix-direnv-template\" --refresh";
    };
    # For Nixd to pick up the nixpkgs.
    # TODO: I need to also add extra config for Nixd.
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
  };
}
