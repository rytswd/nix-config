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
      # Custom Taketomi theme - self-contained Qt6 theme with modern effects.
      # In order to get the theme change to take effect, cache directory
      # may need to be cleared up with:
      #
      #     sudo rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6/qmlcache
      taketomi-theme = pkgs.qt6Packages.callPackage ./taketomi-theme.nix { };

      # NOTE: Extra theme setup by pulling GitHub repos.
      # These will be placed under /run/current-system/sw/share/sddm/themes.
      tokyo-night = pkgs.libsForQt5.callPackage ./tokyo-night.nix { };
      # TODO: tokyo-night is the only one that's working correctly...
      # swish = pkgs.libsForQt5.callPackage ./swish.nix { };
      # bluish = pkgs.libsForQt5.callPackage ./bluish.nix { };
    in [
      taketomi-theme
      tokyo-night
      # swish
      # bluish
    ];
    services.displayManager.sddm = {
      enable = true;
      theme = "taketomi-theme";
    };
  };
}
