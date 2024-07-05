{ pkgs
, lib
, config
, ...}:

{
  options = {
    flatpak.enable = lib.mkEnableOption "Enables flatpak";
  };

  config = lib.mkIf config.flatpak.enable {
    services.flatpak.enable = true;
  };
}
