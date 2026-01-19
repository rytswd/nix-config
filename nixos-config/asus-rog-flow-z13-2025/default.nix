{
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
      inputs
      nixpkgs
      nixpkgs-unstable
      home-manager
      overlays
      ;
  };
  modules = [
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    # disko defines the partition and filesystem setup.
    inputs.disko.nixosModules.disko
    ./disko.nix
    # impermanence makes the whole disk ephemeral unless otherwise specified.
    inputs.impermanence.nixosModules.impermanence
    ../modules/nix-impermanence.nix

    ###----------------------------------------
    ##  Third party solutions
    #------------------------------------------
    inputs.sops-nix.nixosModules.sops
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    # Extra modules based on private setup.
    # inputs.nix-config-private.nixos-modules.civo

    ###----------------------------------------
    ##  Main Configuration
    #------------------------------------------
    # Adjust Nix and Nixpkgs related flags before proceeding.
    ../modules/nix-base.nix
    # hardware.nix has some hardware specific configurations.
    ./hardware.nix
    # configuration.nix pulls in various modules to achieve similar
    # configuration across machines.
    ./configuration.nix

    ###----------------------------------------
    ##  User Setup
    #------------------------------------------
    # Create users.
    ../../user-config/admin/create.nix
    ../../user-config/ryota/create.nix

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

      home-manager.users.admin = {
        imports = [
          ../../user-config/admin/nixos.nix
          # Impermanence setup enabled for this device.
          inputs.impermanence.homeManagerModules.impermanence
          ../../user-config/admin/persist-impermanence.nix
        ];
      };
      home-manager.users.ryota =  {
        imports = [
          ../../user-config/ryota/nixos.nix
          # Impermanence setup enabled for this device.
          inputs.impermanence.homeManagerModules.impermanence
          ../../user-config/ryota/persist-impermanence.nix
        ];
      };
    }
  ];
}
