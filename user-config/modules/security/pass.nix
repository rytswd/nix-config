{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options = {
    # https://www.passwordstore.org/
    security.pass.enable = lib.mkEnableOption "Enable Password Store setup.";
  };

  config = lib.mkIf config.security.pass.enable {
    home.packages = [
      pkgs.pass
    ];
    services.pass-secret-service = {
      enable = true;
    };
  };
}
