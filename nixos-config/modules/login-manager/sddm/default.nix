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
      # These will be placed under /run/current-system/sw/share/sddm/themes.
      tokyo-night = pkgs.libsForQt5.callPackage ./tokyo-night.nix { };
      # TODO: tokyo-night is the only one that's working correctly...
      # swish = pkgs.libsForQt5.callPackage ./swish.nix { };
      bluish = pkgs.libsForQt5.callPackage ./bluish.nix { };
      in [
        tokyo-night
        # swish
        bluish
      ];
    services.displayManager.sddm = {
      enable = true;
      # theme = "maldives";
      theme = "tokyo-night";
      # theme = "swish";
      # theme = "bluish";
    };
  };
}
