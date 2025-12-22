{
  self,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  system,
  overlays,
  inputs,
  ...
}:

nixpkgs-unstable.lib.nixosSystem rec {
  inherit system;
  specialArgs = {
    inherit
      nixpkgs
      nixpkgs-unstable
      home-manager
      overlays
      ;
  };
  modules = [
    inputs.disko.nixosModules.disko

    inputs.sops-nix.nixosModules.sops
    self.inputs.niri.nixosModules.niri
    # inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    # Extra modules based on private setup.
    # inputs.nix-config-private.nixos-modules.civo

    # Adjust Nix and Nixpkgs related flags before proceeding.
    ./nix-flags.nix

    # Start with the hardware configuration around M1 VM first.
    ./hardware.nix

    # Manage system wide configurations here.
    ./configuration.nix

    # Create users.
    ../../user-config/admin/create.nix
    ../../user-config/ryota/create.nix
    # ../../user-config/rytswd/create.nix

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager
    {
      # NOTE: Without this, I get an error applying home-manager updates
      # (following the addition of GTK config).
      home-manager.backupFileExtension = "backup";

      # NOTE: I'm depending on the NixOS packages, but I shouldn't need to for
      # home-manager. This is something I need to sort out.
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # home-manager.sharedModules = [
      #   # Placeholder
      # ];
      home-manager.extraSpecialArgs = { inherit inputs; };

      # Each user needs to be set up separately. Because home-manager needs to
      # know where the home directory is, I need to specify the username again.
      home-manager.users.admin = ../../user-config/admin/nixos.nix;
      home-manager.users.ryota = ../../user-config/ryota/nixos.nix;
    }
  ];
}
