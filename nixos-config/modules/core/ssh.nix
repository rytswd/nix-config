{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.ssh.enable = lib.mkEnableOption "Enable ssh.";
  };

  config = lib.mkIf config.core.ssh.enable {
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
  };
}
