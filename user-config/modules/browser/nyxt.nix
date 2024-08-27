{ pkgs
, lib
, config
, ...}:

{
  options = {
    browser.nyxt.enable = lib.mkEnableOption "Enable Nyxt.";
  };

  config = lib.mkIf config.browser.nyxt.enable {
    home.packages = [ pkgs.nyxt ];
  };
}
