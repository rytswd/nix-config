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
      pkgs.nix-output-monitor
      pkgs.nvd
      pkgs.nh
    ];
  };
}
