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
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
