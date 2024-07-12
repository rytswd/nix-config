{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.nix.enable = lib.mkEnableOption "Enable Nix development related tools.";
  };

  config = lib.mkIf config.programming-language.nix.enable {
    home.packages = [
      pkgs.nix-output-monitor
      pkgs.nvd
      pkgs.nh
    ];
  };
}
