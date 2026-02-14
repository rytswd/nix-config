{
  nixpkgs,
  nixpkgs-unstable,
  system,
  overlays,
  inputs,
  ...
}:

nixpkgs-unstable.lib.nixosSystem rec {
  inherit system;
  specialArgs = {
    inherit
      inputs
      nixpkgs
      nixpkgs-unstable
      overlays
      ;
  };
  modules = [
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    inputs.disko.nixosModules.disko
    ../disko.nix

    ###----------------------------------------
    ##  Main Configuration
    #------------------------------------------
    ../../modules/nix-base.nix
    ../configuration.nix

    ###----------------------------------------
    ##  Node Identity
    #------------------------------------------
    {
      networking.hostName = "hetzner-k8s-cp-3";
    }
  ];
}
