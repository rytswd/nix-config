{ pkgs, ... }:
# Zoom — not imported by the communication bundle's default.nix. Import this
# leaf directly from a host config if you actually want it.
{
  home.packages = [ pkgs.zoom-us ];

  xdg.configFile."zoomus.conf" = {
    text = ''
      [General]
      xwayland=false
      enableWaylandShare=true
    '';
  };
}
