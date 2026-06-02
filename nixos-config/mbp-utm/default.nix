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

# UTM-hosted aarch64-linux NixOS VM on Apple Silicon. Configuration shape
# intentionally mirrors `nixos-config/asus-rog-flow-z13-2025/` and
# `asus-rog-zephyrus-g14-2024/`; the per-host differences (no disko / no
# impermanence / no Limine / no asus quirks / UTM guest agents) are
# documented inside `configuration.nix`.

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
  modules = [
    ###----------------------------------------
    ##  Disk setup
    #------------------------------------------
    # disko defines the partition and filesystem setup.
    # NOTE: disko isn't used for this machine -- UTM provisions the disk
    # via its installer and `hardware.nix` mounts it by label.
    # inputs.disko.nixosModules.disko
    # ./disko.nix

    # NOTE: This machine doesn't use impermanence.
    # inputs.impermanence.nixosModules.impermanence
    # "${self}/nixos-config/modules/nix-impermanence.nix"

    ###----------------------------------------
    ##  Third party solutions
    #------------------------------------------
    inputs.sops-nix.nixosModules.sops
    inputs.niri.nixosModules.niri
    # inputs.cosmic.nixosModules.default

    ###----------------------------------------
    ##  Extra configuration
    #------------------------------------------
    # Extra modules based on private setup.
    # inputs.nix-config-private.nixos-modules.work

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
    # Adjust Nix and Nixpkgs related flags before proceeding.
    "${self}/nixos-config/modules/nix-base.nix"
    # hardware.nix has some hardware specific configuration for this device.
    ./hardware.nix
    # configuration.nix pulls in various modules to achieve similar
    # configuration across machines.
    ./configuration.nix

    ###----------------------------------------
    ##  User Setup
    #------------------------------------------
    # Create users.
    # `admin` is created alongside `ryota` because the private users module
    # (`nix-config-private.nixosModules.users`) attaches a hashedPassword to
    # `users.users.admin` unconditionally, which requires the admin user to
    # actually be declared. Cheap to keep -- it's a wheel-capable rescue
    # account, useful in a VM you might brick.
    # TODO: Remove the admin user which won't have much use in VM env.
    "${self}/user-config/admin/create.nix"
    "${self}/user-config/ryota/create.nix"

    inputs.nix-config-private.nixosModules.users

    # Set up home-manager and users.
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        # NOTE: Without this, I get an error applying home-manager updates
        # (following the addition of GTK config).
        backupFileExtension = "backup";

        # Because of pkgs shadowing below, we technically don't need any
        # extra adjustment to global pkgs. Keeping this to true is
        # slightly cleaner.
        useGlobalPkgs = true;
        # Set to true for using /etc/profiles/per-user/username/ path.
        useUserPackages = true;

        # Update pkgs to point to nixpkgs-unstable.
        extraSpecialArgs = {
          inherit self inputs;
          pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            overlays = overlays;
          };
        };

        # Each user needs to be set up separately.
        # Because home-manager needs to know where the home directory is,
        # I need to specify the username again.

        users.ryota = {
          imports = [
            "${self}/user-config/ryota/nixos.nix"
          ];
          # mbp-utm is a stripped-down VM -- skip the vendor product
          # bundles imported by `user-config/ryota/nixos.nix`. The paths
          # below match exactly how they appear in that file's `imports`
          # list (bare directory paths -- module-system canonicalisation
          # resolves them to each bundle's `default.nix`).
          disabledModules = [
            "${self}/user-config/modules/product/vcs"
            "${self}/user-config/modules/product/collaboration"
          ];
        };
      };
    }
  ];
}
