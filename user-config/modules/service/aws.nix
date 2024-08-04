{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.aws.enable = lib.mkEnableOption "Enable AWS related tooling.";
  };

  config = lib.mkIf config.service.aws.enable {
    home.packages = [
      pkgs.awscli2
    ];
  };
}
