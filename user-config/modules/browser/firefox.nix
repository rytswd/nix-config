{ pkgs
, lib
, config
, ...}:

{
  options = {
    browser.firefox.enable = lib.mkEnableOption "Enable Firefox.";
  };

  config = lib.mkIf config.browser.firefox.enable {
    programs.firefox = {
      enable = true;
    };
    home.packages = [
      pkgs.librewolf
    ];
  };
}
