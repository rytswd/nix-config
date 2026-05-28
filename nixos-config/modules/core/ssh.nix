{
  services.openssh = {
    # Enable the OpenSSH daemon.
    enable = true;
    ports = [8422];

    # TODO: Review these settings, not meant to be a permanent setup.
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };
}
