{ pkgs
, lib
, config
, ...}:

{
  options = {
    music.spotify.enable = lib.mkEnableOption "Enable Spotify.";
  };

  config = lib.mkIf config.music.spotify.enable {
    home.packages = [ pkgs.spotify ];
  };
}
