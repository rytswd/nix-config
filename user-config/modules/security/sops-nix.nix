{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options = {
    security.sops-nix.enable = lib.mkEnableOption "Enable SOPS Nix setup.";
  };

  config = lib.mkIf config.security.sops-nix.enable {
    sops = {
      # Dummy data, this definition is actually provided by module definition
      # in the private repo. There is a strong assertion in place and when not
      # provided, this would cause eval time error.
      defaultSopsFile = lib.mkDefault "/dummy.yaml";
      defaultSopsFormat = "yaml";

      # Dummy data, this definition is actually provided by module definition
      # in the private repo. There is a strong assertion in place and when not
      # provided, this would cause eval time error.
      age.keyFile = lib.mkDefault "dummy.txt";
    };
  };
}
