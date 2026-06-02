{ pkgs, ... }:
{
  # libnotify -- provides `notify-send` and the client library used by app code.
  home.packages = [ pkgs.libnotify ];
}
