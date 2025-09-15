{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    window-manager.niri.enable = lib.mkEnableOption "Enable Niri user settings.";
  };

  config = lib.mkIf config.window-manager.niri.enable {
    # Because the config is quite lengthy, I'm simply mapping a file into the
    # XDG directory. All the code is generated with the Org Mode tangle.
    xdg.configFile = {
      "niri/config.kdl".source = ./config.kdl;
    };
    home.packages = [
      pkgs.xwayland-satellite
    ];
    home.shellAliases = {
      "nirimvw" = "niri msg action move-window-to-workspace";
    };
    xdg.portal = {
      enable = true;
      extraPortals = [
        # niri needs this for screen cast.
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
