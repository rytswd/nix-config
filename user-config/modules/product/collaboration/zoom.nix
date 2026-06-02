{ config, pkgs, lib, ... }:
# `zoom-us` is built only for x86_64-linux and {x86_64,aarch64}-darwin --
# importing this leaf on aarch64-linux (e.g. UTM VM) would otherwise fail
# evaluation. `config.local.availablePackages` drops it silently when the
# host can't build it. The zoomus.conf drop-in is harmless to leave in
# place but is pointless without the binary, so we gate it too.
let
  zoomAvailable = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.zoom-us;
in
{
  home.packages = config.local.availablePackages [ pkgs.zoom-us ];

  xdg.configFile."zoomus.conf" = lib.mkIf zoomAvailable {
    text = ''
      [General]
      xwayland=false
      enableWaylandShare=true
    '';
  };
}
