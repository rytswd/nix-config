{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.fly.enable = lib.mkEnableOption "Enable Fly.io related tooling.";
  };

  config = lib.mkIf config.service.fly.enable {
    home.packages = [
      pkgs.flyctl
    ];
  };
}
