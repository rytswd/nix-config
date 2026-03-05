{
  pkgs,
  lib,
  config,
  ...
}:

# Because this module is specific to laptop, the import of this module would
# directly enable the laptop related configuration.

{
  # Ref: https://discourse.nixos.org/t/battery-life-still-isnt-great/41188/3
  # TODO: I need to review this more closely, it's working OK but could be better.
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };
  services = {
    logind.settings.Login = {
      HandleLidSwitch = "suspend"; # on battery → sleep
      HandleLidSwitchExternalPower = "ignore"; # on AC → do nothing (keep running)
    };
    thermald.enable = true;
    power-profiles-daemon.enable = false;
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
  };
}
