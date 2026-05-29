{
  pkgs,
  lib,
  config,
  ...
}:
# swaync — SwayNotificationCenter. Not imported by the notification bundle's
# default.nix; import this leaf directly from a host config if you want it.
{
  services.swaync.enable = true;
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
}
