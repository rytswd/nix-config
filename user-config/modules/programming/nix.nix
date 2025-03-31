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
      pkgs.nixd # Language Server
      pkgs.nixpkgs-review # PR review utility
    ] ++ [
      # Because of Darwin support provided by a separate flake, this ensures
      # there is no conflicting package on macOS. NixOS technically doesn't need
      # this setup if nh is made available on NixOS level.
      (if pkgs.stdenv.isDarwin then {} else pkgs.nh)
    ];
    home.shellAliases = {
      flakeinit = "nix flake init -t \"github:rytswd/nix-direnv-template\" --refresh";
    };
    # For Nixd to pick up the nixpkgs.
    # TODO: I need to also add extra config for Nixd.
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
  };
}
