{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.slack.enable = lib.mkEnableOption "Enable Slack.";
  };

  config = lib.mkIf config.communication.slack.enable {
    home.packages = [ pkgs.slack ];
  };
}
