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
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
      };
    };
    services.pass-secret-service = {
      enable = true;
    };
  };
}
