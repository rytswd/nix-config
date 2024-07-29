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

      # GPG agent keeps the cache of the key, and set TTL (time-to-live) of
      # 600sec by default. Whenever the cache is accessed, the timer is reset.
      #
      # There are two separate fields: "default cache ttl" and "max cache ttl".
      # The "default cache ttl" is about the ttl set to the cache every time the
      # cache is accessed. On the other hand, the "max cache ttl" is the time
      # limit when the cache will be invalidated regardless of how recently the
      # cache was accessed. So, for that reason, it does not make sense to have
      # a longer "default cache ttl" value than "max cache ttl".
      #
      # Ref: https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      #
      # I'm setting this to be a practically one time operation at the beginning
      # of the day, and the cache to expire at least after a week.
      defaultCacheTtl = (3600 * 24);
      defaultCacheTtlSsh = (3600 * 24);
      maxCacheTtl = (3600 * 24 * 7);
      maxCacheTtlSsh = (3600 * 24 * 7);

      # Allow use of GPG keys for SSH.
      enableSshSupport = true;
      sshKeys = [
        # Provide the keygrip
        "0D289B68FD943DE2E94B37FF33D03DEB5275FB51"
      ];
    };
  };
}
