{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.locale.enable = lib.mkEnableOption "Enable locale settings.";
  };

  config = lib.mkIf config.core.locale.enable {
    # Set your time zone.
    time.timeZone = "Europe/London";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";
  };
}
