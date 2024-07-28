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
        # disabling the built-in ccid handling from scdaemon. This is a setting
        # for the host machine, and not for home-manager to handle.
        disable-ccid = true;
      };
    };
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;

      # Allow use of GPG keys for SSH.
      enableSshSupport = true;
      sshKeys = [
        # Provide the keygrip
        "0D289B68FD943DE2E94B37FF33D03DEB5275FB51"
      ];
    };
  };
}
