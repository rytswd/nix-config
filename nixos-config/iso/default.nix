{
  self,
  nixpkgs-unstable,
  inputs,
  system,
  ...
}:

nixpkgs-unstable.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self inputs; };
  modules = [
    "${nixpkgs-unstable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ./configuration.nix
  ];
}
