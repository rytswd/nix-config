{ pkgs
, lib
, config
, ...}:

{
  options = {
    security.pam.enable = lib.mkEnableOption "Enable PAM.";
  };

  config = lib.mkIf config.security.pam.enable {
    security.pam.u2f = {
      enable = true;
      control = "sufficient";  # "required" or "sufficient" (optional 2FA)
      settings = {
        origin = "pam://shared";
        appid = "pam://shared";
      };
    };
    security.pam.services = {
      sudo.u2fAuth = true;
      login.u2fAuth = true;
    };
  };
}
