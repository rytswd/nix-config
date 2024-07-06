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
      tokyo-night-sddm = pkgs.libsForQt5.callPackage
        ./tokyo-night-sddm.nix { };
      in [
        tokyo-night-sddm
      ];
    services.displayManager.sddm = {
      enable = true;
      # theme = "maldives";
      theme = "tokyo-night-sddm";
    };
  };
}
