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
      # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".beta
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
    ];

    # NOTE: Zen Browser does not have config sync between machines. For now, I'm
    # simply copying the config over using rsync.
    #
    #    rsync -avz -e "ssh -p 8422" ~/.zen/ user@REMOTE:~/.zen/
  };
}
