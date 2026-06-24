{
  self,
  nixpkgs,
  nixpkgs-unstable,
  system,
  overlays,
  inputs,
  ...
}:

nixpkgs-unstable.lib.nixosSystem {
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
    ##  Disk setup (ZFS striped io2 + L2ARC)
    #------------------------------------------
    inputs.disko.nixosModules.disko
    "${self}/nixos-config/ryota-aws-ec2-devbox/disko.nix"

    ###----------------------------------------
    ##  Main Configuration
    #------------------------------------------
    "${self}/nixos-config/modules/nix-base.nix"
    "${self}/nixos-config/ryota-aws-ec2-devbox/configuration.nix"
  ];
}
