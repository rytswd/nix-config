{
  self,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  ...
}@machineArgs:

nixpkgs.lib.nixosSystem rec {
  inherit system;
  specialArgs = {
    inherit
      self
      inputs
      nixpkgs
      nixpkgs-unstable
      home-manager
      overlays
      ;
  };
  modules = import ./modules.nix machineArgs;
}
