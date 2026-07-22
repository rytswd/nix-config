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
  # `powertop.enable` only wires the boot-time auto-tune service; it doesn't
  # put the binary on PATH. Add it here (laptop-only, sudo-reachable) for
  # interactive use.
  #
  # `power-mode` is a manual override toggle. auto-cpufreq below only manages
  # the governor + turbo, deliberately NOT the EPP or ASUS platform_profile,
  # so the machine stays at its high-power default (EPP/profile = performance)
  # and these manual writes are not fought by the daemon. Use it to drop into
  # a lower-power state on demand (even while on AC) and back:
  #
  #     power-mode            # show current EPP / platform_profile / AC state
  #     power-mode eco        # quiet + lowest power
  #     power-mode balanced   # middle ground
  #     power-mode performance# back to default
  #
  environment.systemPackages = [
    pkgs.powertop
    (pkgs.writeShellScriptBin "power-mode" ''
      set -euo pipefail
      # Writing to sysfs needs root; self-elevate.
      if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi

      mode="''${1:-status}"
      pp=/sys/firmware/acpi/platform_profile

      setepp() {
        for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          echo "$1" > "$f"
        done
      }
      setpp() { [ -w "$pp" ] && echo "$1" > "$pp" || true; }

      case "$mode" in
        performance|perf|max)
          setepp performance; setpp performance
          echo "power-mode -> performance (EPP=performance, profile=performance)" ;;
        balanced|bal)
          setepp balance_power; setpp balanced
          echo "power-mode -> balanced (EPP=balance_power, profile=balanced)" ;;
        eco|save|low)
          setepp power; setpp quiet
          echo "power-mode -> eco (EPP=power, profile=quiet)" ;;
        status|"")
          echo "EPP:              $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
          echo "platform_profile: $(cat "$pp" 2>/dev/null || echo n/a)"
          echo "on AC:            $(cat /sys/class/power_supply/A*/online 2>/dev/null | head -1)" ;;
        *)
          echo "usage: power-mode {performance|balanced|eco|status}" >&2
          exit 1 ;;
      esac
    '')
  ];
  services = {
    logind.settings.Login = {
      # Suspend on lid close regardless of power source. To keep the system
      # running with the lid closed, use the noctalia lid-toggle inhibitor
      # (rytswd/noctalia-extra) instead.
      HandleLidSwitch = "suspend";
    };
    thermald.enable = true;
    power-profiles-daemon.enable = false;
    upower.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
        # NOTE: intentionally only `governor` + `turbo` here. EPP and
        # platform_profile are left unmanaged so `power-mode` (above) can
        # override them on demand without auto-cpufreq reverting the change.
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
