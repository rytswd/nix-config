{ pkgs, inputs, ... }:
# LibrePods -- AirPods control daemon for Linux. Not imported by the
# devices bundle's default.nix -- import this leaf directly from a host
# config when the machine actually pairs with AirPods.
#
# Upstream: https://github.com/kavishdevar/librepods
let
  librepods = inputs.librepods.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [ librepods ];

  # Per-user-session autostart, declared at the NixOS layer so it's a
  # machine capability (every graphical session on this box gets librepods
  # in the tray), not a per-user preference. `WantedBy graphical-session.target`
  # means it only fires when a real graphical session is up -- TTY-only
  # logins (root recovery, SSH-only) won't try to start the tray.
  systemd.user.services.librepods = {
    description = "LibrePods -- AirPods control daemon (tray)";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${librepods}/bin/librepods --start-minimized";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
