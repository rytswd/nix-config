{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    wallpaper.swww.enable = lib.mkEnableOption "Enable swww.";
  };

  config = lib.mkIf config.wallpaper.swww.enable {
    home.packages = [
      inputs.swww.packages.${pkgs.stdenv.hostPlatform.system}.swww
    ];
  };
}
