{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    # NOTE:
    # PAM (Pluggable Authentication Module) that integrates U2F (Universal 2nd Factor)
    security.pam-u2f.enable = lib.mkEnableOption "Enable PAM U2F setup.";
  };

  config = lib.mkIf config.security.pam-u2f.enable {
    xdg.config = {
      "Yubico/u2f_keys".source = ./u2f-keys.txt;
    };
  };
}
