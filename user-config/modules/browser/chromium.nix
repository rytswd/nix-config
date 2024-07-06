{ pkgs
, lib
, config
, ...}:

{
  options = {
    browser.chromium.enable = lib.mkEnableOption "Enable Chromium.";
  };

  config = lib.mkIf config.browser.chromium.enable {
    # TODO: Check if this is all I need.
    # TODO: Check puppetteer and other tools
    home.packages = [ pkgs.chromium ];
  };
}
