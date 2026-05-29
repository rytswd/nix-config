{
  security.pam.u2f = {
    enable = true;
    control = "sufficient"; # "required" or "sufficient" (optional 2FA)
    settings = {
      origin = "pam://shared";
      appid = "pam://shared";
    };
  };
  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
  };
}
