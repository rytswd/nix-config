{
  self,
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
      self
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
    "${self}/nixos-config/hetzner-k8s/disko.nix"

    ###----------------------------------------
    ##  Main Configuration
    #------------------------------------------
    "${self}/nixos-config/modules/nix-base.nix"
    "${self}/nixos-config/hetzner-k8s/configuration.nix"

    ###----------------------------------------
    ##  Node Identity
    #------------------------------------------
    {
      networking.hostName = "hetzner-k8s-cp-1";
    }
  ];
}
