{ pkgs
, lib
, config
, ...}:

{
  options = {
    security.age.enable = lib.mkEnableOption "Enable age setup.";
  };

  config = lib.mkIf config.security.age.enable {
    home.packages = [
      pkgs.age
    ];
  };
}
