{ pkgs
, lib
, config
, ...}:

{
  options = {
    browser.vivaldi.enable = lib.mkEnableOption "Enable Vivaldi.";
  };

  config = lib.mkIf config.browser.vivaldi.enable {
    home.packages = [ pkgs.vivaldi ];
  };
}
