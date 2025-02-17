{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    browser.zen.enable = lib.mkEnableOption "Enable Zen Browser.";
  };

  config = lib.mkIf config.browser.zen.enable {
    home.packages = [
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".beta
    ];
  };
}
