{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./ollama.nix
    ./keybase.nix
    ./proton-pass.nix
    ./civo.nix
    ./aws.nix
    ./gcp.nix
    ./fly.nix
    ./terraform.nix
    ./surrealdb.nix
  ];

  service.ollama.enable = lib.mkDefault true;
  service.keybase.enable = lib.mkDefault true;
  service.proton-pass.enable = lib.mkDefault true;
  service.civo.enable = lib.mkDefault true;
  service.aws.enable = lib.mkDefault true;
  service.gcp.enable = lib.mkDefault true;
  service.fly.enable = lib.mkDefault true;
  service.terraform.enable = lib.mkDefault true;
  service.surrealdb.enable = lib.mkDefault true;
}
