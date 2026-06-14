{ lib, inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    # `local.secrets.enable` lives here so it is in scope on every host
    # that imports the security bundle (alongside the `sops.*` options).
    ../lib/secrets.nix
  ];

  sops = {
    # Dummy data, this definition is actually provided by module definition
    # in the private repo. There is a strong assertion in place and when not
    # provided, this would cause eval time error.
    defaultSopsFile = lib.mkDefault "/dummy.yaml";
    defaultSopsFormat = "yaml";

    # Dummy data, this definition is actually provided by module definition
    # in the private repo. There is a strong assertion in place and when not
    # provided, this would cause eval time error with sops-nix.
    age.keyFile = lib.mkDefault "dummy.txt";
    # age.requirePcscd = lib.mkForce false; # YubiKey setup from my fork.
  };
}
