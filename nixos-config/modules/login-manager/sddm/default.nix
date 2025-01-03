{ pkgs
, lib
, config
, ...}:

{
  options = {
    login-manager.sddm.enable = lib.mkEnableOption "Enable sddm.";
  };

  config = lib.mkIf config.login-manager.sddm.enable {
    environment.systemPackages = let
      # NOTE: Extra theme setup by pulling GitHub repos.
      tokyo-night = pkgs.callPackage ./tokyo-night.nix { };
      bluish = pkgs.callPackage ./bluish.nix { };
      in [
        tokyo-night
        bluish
      ];
    services.displayManager.sddm = {
      enable = true;
      # theme = "maldives";
      # theme = "tokyo-night";
      theme = "bluish";
    };
  };
}
