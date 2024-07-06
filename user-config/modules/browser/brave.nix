{ pkgs
, lib
, config
, ...}:

{
  options = {
    browser.brave.enable = lib.mkEnableOption "Enable Brave.";
  };

  config = lib.mkIf config.browser.brave.enable {
    home.packages = [ pkgs.brave ];
  };
}
