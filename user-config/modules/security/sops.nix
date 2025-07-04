{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    security.sops.enable = lib.mkEnableOption "Enable SOPS setup.";
  };

  # NOTE: SOPS setup here does not use SOPS Nix, check sops-nix.nix instead.
  config = lib.mkIf config.security.sops.enable {
    home.packages = [
      pkgs.sops
    ];

    xdg.configFile = {
      "sops/age/keys.txt".source = ./sops-keys.txt;
    };
  };
}
