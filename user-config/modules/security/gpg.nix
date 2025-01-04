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
        # NOTE: The below can be used to debug the behaviour.
        # log-file = "/var/lib/scdaemon.log";
        # debug-level = "advanced";

        # reader-port = "Yubico Yubi";

        # Because YubiKey setup is handled by pcscd (PC/SC Smart Card Daemon),
        # disabling the built-in ccid handling from scdaemon. This is a setting
        # for the host machine, and not for home-manager to handle.
        disable-ccid = true;
        # NOTE: I had to remove the above line after upgrading nixpkgs; this
        # was then confirmed to be the culprit of some GPG based actions to
        # fail, such as SOPS usage. Adding this back resolved the issue, but
        # I have never got to the bottom of why this setup wasn't working in
        # the first place.
      };
    };
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-rofi;

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
        # Provide the keygrip:
        # This can be retrieved from ~/.gnupg/sshcontrol
        # ECC
        "437EC237AB5254CF769090431321D9446B182C86"
        # RSA
        # "0D289B68FD943DE2E94B37FF33D03DEB5275FB51"
      ];
    };
  };
}
