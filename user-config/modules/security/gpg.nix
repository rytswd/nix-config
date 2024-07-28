{ pkgs
, lib
, config
, ...}:

{
  options = {
    security.gpg.enable = lib.mkEnableOption "Enable GPG setup.";
  };

  config = lib.mkIf config.security.gpg.enable {
    programs.gpg = {
      enable = true;
      package = pkgs.gnupg;
      scdaemonSettings = {
        # Because YubiKey setup is handled by pcscd (PC/SC Smart Card Daemon),
        # disabling the built-in ccid handling from scdaemon.
        disable-ccid = true;
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
