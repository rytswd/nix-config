{ pkgs, ... }:
# ytmdesktop — https://github.com/ytmdesktop/ytmdesktop
#
# NOTE: there's also `pkgs.youtube-music` (the th-ch/youtube-music fork,
# being renamed to `pear-desktop` in current nixpkgs) — different project,
# don't confuse the two.
{
  home.packages = [ pkgs.ytmdesktop ];
}
