{ pkgs, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # Ensure network manager is a part of the config even when I don't have any
  # desktop manager like GNOME.
  networking.networkmanager.enable = true;

  ###----------------------------------------
  ##   Wi-Fi regulatory domain
  #------------------------------------------
  # Pin the regulatory domain to US. Without an explicit country cfg80211 boots
  # into the world domain ("00"), which does not permit 6 GHz. The AP's Country
  # IE only moves it there transiently -- the journal shows `REGDOM-CHANGE
  # init=COUNTRY_IE type=COUNTRY alpha2=US`, then `regulatory prevented using AP
  # config, downgraded`, then a revert to `init=CORE type=WORLD`.
  #
  # The visible symptom is not "no 6 GHz" but a link that drops every few
  # minutes: the mt7925 keeps deciding to roam onto a 6 GHz BSSID, tears down
  # the working association first, and the auth is then refused by the
  # regulatory core -- `SME: Authentication request to the driver failed`.
  # Measured as ~195 such failures over 48h, every one to a 6 GHz frequency
  # (6295 / 6935 MHz), across two different networks.
  #
  # wireless-regdb is already on the system -- it arrives via
  # `hardware.enableRedistributableFirmware` -- so the table was never the
  # missing piece; nothing was selecting a row from it. The option is set
  # explicitly anyway to keep the pairing obvious and to survive a change in
  # what the firmware bundle happens to pull in.
  #
  # Takes effect on reboot (or a cfg80211 reload); verify with
  # `cat /sys/module/cfg80211/parameters/ieee80211_regdom` -- expect `US`.
  #
  # NOTE: there is a matching runtime workaround applied out-of-band with
  # `nmcli connection modify "IFT Admin" 802-11-wireless.band a`, which hides
  # the 6 GHz BSSIDs from that profile entirely. It is NOT represented in this
  # repo (NM profiles are mutable state). Once the domain reads `US`, clear it
  # with `802-11-wireless.band ""` to get 6 GHz back -- and re-test, because
  # mt7925 6 GHz has its own history; this option only makes the band legal,
  # not necessarily reliable.
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';

  ###----------------------------------------
  ##   Wi-Fi link stability
  #------------------------------------------
  # Wi-Fi power save drops beacons on the mt7925 (Flow Z13), which shows up as
  # stalls and dropped associations even at 100% signal. The battery cost is
  # real, but small next to a link that has to re-associate to recover.
  #
  # NOTE: `powerManagement.powertop.enable` (laptop.nix) runs `powertop
  # --auto-tune` at boot and turns Wi-Fi power save back ON. NM wins in
  # practice because it applies this per-association, i.e. after the boot-time
  # auto-tune has run -- but if power save ever shows as `on` in
  # `iw dev <if> get power_save` while associated, powertop is the suspect.
  networking.networkmanager.wifi.powersave = false;

  # NM gives up on a profile after 4 failed activations and then waits for a
  # user action, which dead-ends this machine: after resume wpa_supplicant
  # sometimes times out the 4-way handshake (`reason=15`) and reports it as
  # WRONG_KEY, so NM invalidates the stored PSK, asks a secret agent for a new
  # one, finds none running under niri ("no secrets: No agents were available")
  # and stays offline until a manual reconnect.
  #
  # 0 = retry forever. Why not run a secret agent instead (nm-applet et al):
  # the PSK is already stored system-wide (`psk-flags=0`), so there is nothing
  # for an agent to supply -- the ask is spurious and retrying is the honest
  # fix. It also keeps this working on a headless/locked session.
  networking.networkmanager.connectionConfig."connection.autoconnect-retries" = 0;

  # Belt-and-braces for the same failure mode: if Wi-Fi is still down ~30s
  # after resume, kick NM once. A normal resume is a no-op -- the loop exits as
  # soon as the device reports `connected`.
  #
  # Why not `powerManagement.resumeCommands`: that body runs inside
  # systemd-suspend.service, so the polling loop would block the resume path.
  # `After` + `WantedBy` on suspend.target is the standard way to order work
  # onto the way back up instead.
  systemd.services.wifi-resume-reconnect = {
    description = "Re-activate Wi-Fi if it did not return after resume";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "NetworkManager.service"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "wifi-resume-reconnect" ''
          set -eu
          nmcli="${pkgs.networkmanager}/bin/nmcli"

          # grep/cut rather than awk: systemd gives this unit a minimal PATH
          # (coreutils, findutils, grep, sed, systemd) and awk is not on it, so
          # an awk-based parse silently yields nothing and the whole check
          # becomes a no-op. `|| true` keeps a no-match from tripping `set -e`.
          wifi_field() {
            "$nmcli" -t -f TYPE,"$1" device status |
              { grep -m1 '^wifi:' || true; } |
              cut -d: -f2
          }

          # Give NM's own retry a fair chance before stepping in.
          for _ in $(seq 1 15); do
            sleep 2
            if [ "$(wifi_field STATE)" = "connected" ]; then
              exit 0
            fi
          done

          dev=$(wifi_field DEVICE)
          if [ -n "$dev" ]; then
            echo "wifi still down after resume, re-activating $dev"
            "$nmcli" device connect "$dev" || true
          fi
        ''
      );
    };
  };
}
