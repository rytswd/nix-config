{ self
, nixpkgs
, nixpkgs-unstable
, darwin
, home-manager
, system
, overlays
, inputs
, ...
}:

darwin.lib.darwinSystem {
  inherit system;
  specialArgs = {
    inherit
      self
      nixpkgs
      nixpkgs-unstable
      home-manager
      overlays
      inputs
      ;
  };
  modules = [
    ###----------------------------------------
    ##  Third party solutions
    #------------------------------------------
    # SrvOS terminfo entries (so ssh-ing from this host into NixOS gets
    # the right TERM behaviour). `srvos.darwinModules.common` is
    # intentionally skipped — it references the legacy `homebrew.prefix`
    # attribute that current nix-darwin has removed.
    inputs.srvos.darwinModules.mixins-terminfo

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
    # configuration.nix pulls in the per-host module list.
    ./configuration.nix

    ###----------------------------------------
    ##  User Setup
    #------------------------------------------
    "${self}/user-config/ryota/create.nix"

    ###----------------------------------------
    ##  Home Manager
    #------------------------------------------
    home-manager.darwinModules.home-manager
    "${self}/shared/home-manager.nix"
    {
      home-manager = {
        extraSpecialArgs = { inherit self inputs; };

        users.ryota = {
          imports = [
            "${self}/user-config/ryota/macos.nix"
            # darwin-only HM modules layered on top of the cross-platform
            # HM config imported by ryota/macos.nix itself.
            "${self}/user-config/modules/darwin-defaults"
            "${self}/user-config/modules/appearance/font.nix"
          ];
        };
      };
    }
  ];
}
