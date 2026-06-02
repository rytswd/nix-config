{ pkgs, lib, ... }:
# `zoom-us` is built only for x86_64-linux and {x86_64,aarch64}-darwin —
# importing this leaf on aarch64-linux (e.g. UTM VM) would otherwise fail
# evaluation. Gracefully skip the install on unsupported platforms; the
# zoomus.conf drop-in is harmless to leave in place but is similarly
# pointless without the binary, so we gate it too.
let
  zoomAvailable = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.zoom-us;
in
{
  home.packages = lib.optionals zoomAvailable [ pkgs.zoom-us ];

  xdg.configFile."zoomus.conf" = lib.mkIf zoomAvailable {
    text = ''
      [General]
      xwayland=false
      enableWaylandShare=true
    '';
  };
}
