{
  self,
  nixpkgs,
  nixpkgs-unstable,
  system,
  overlays,
  inputs,
  home-manager,
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

    ###----------------------------------------
    ##  Home Manager (integrated)
    #------------------------------------------
    # Same wiring as the laptop hosts so a fresh nixos-anywhere install
    # produces a fully-configured box in one shot. The profile is the
    # headless `server.nix` (not `nixos.nix` — no desktop/windowing here).
    # Standalone stays available via homeConfigurations."ryota@ryota-aws-ec2-devbox".
    home-manager.nixosModules.home-manager
    "${self}/shared/home-manager.nix"
    {
      home-manager = {
        extraSpecialArgs = {
          inherit self inputs;
          pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            overlays = overlays;
          };
        };
        users.ryota = {
          imports = [ "${self}/user-config/ryota/server.nix" ];
        };
      };
    }
  ];
}
