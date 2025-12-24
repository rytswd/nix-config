{ pkgs
, lib
, config
, inputs
, osConfig ? {}
, ...}:

let
  # Map hostname to output config file
  outputConfigByHostname = {
    "asus-rog-flow-z13-2025" = ./output-asus-rog-flow-z13-2025.kdl;
    "asus-rog-zephyrus-g14-2024" = ./output-asus-rog-zephyrus-g14-2024.kdl;
  };

  # Determine default output config based on hostname
  defaultOutputConfig =
    if osConfig ? networking.hostName
    then outputConfigByHostname.${osConfig.networking.hostName} or ./output-asus-rog-zephyrus-g14-2024.kdl
    else ./output-asus-rog-zephyrus-g14-2024.kdl;
in
{
  options = {
    window-manager.niri.enable = lib.mkEnableOption "Enable Niri user settings.";

    window-manager.niri.outputConfig = lib.mkOption {
      type = lib.types.path;
      default = defaultOutputConfig;
      description = "Path to the output.kdl file for device-specific display configuration";
      example = lib.literalExpression "./output-asus-rog-flow-z13-2025.kdl";
    };
  };

  config = lib.mkIf config.window-manager.niri.enable {
    # Because the config is quite lengthy, I'm simply mapping a file into the
    # XDG directory. All the code is generated with the Org Mode tangle.
    xdg.configFile = {
      "niri/config.kdl".source = ./config.kdl;
      "niri/output.kdl".source = config.window-manager.niri.outputConfig;
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
