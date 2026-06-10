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
    inputs.srvos.darwinModules.mixins-terminfo

    ###----------------------------------------
    ##  Main configuration
    #------------------------------------------
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
            "${self}/user-config/modules/darwin-defaults"
            "${self}/user-config/modules/appearance/font.nix"
          ];
        };
      };
    }
  ];
}
