{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    wallpaper.awww.enable = lib.mkEnableOption "Enable awww.";
  };

  config = lib.mkIf config.wallpaper.awww.enable {
    home.packages = [
      inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    ];
  };
}
