{ pkgs
, lib
, config
, ...}:

{
  options = {
    notification.swaync.enable = lib.mkEnableOption "Enable swaync setup.";
  };

  config = lib.mkIf config.notification.swaync.enable {
    services.swaync = {
      enable = true;

    };
    xdg.configFile = {
      "swaync".source = ./config;
      "swaync".recursive = true;
    };

    # Because the upstream setup is quite limiting, I'm creating my own
    # systemd configuration here.
    systemd.user.services.swaync = {
      Unit.ConditionEnvironment = lib.mkForce ""; # Updated.
      Service.ExecStart = lib.mkForce "${pkgs.swaynotificationcenter}/bin/swaync -c ${config.xdg.configHome}/swaync/config.json -s ${config.xdg.configHome}/swaync/style.gen.css";
    };
  };
}
