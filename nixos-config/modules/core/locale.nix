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
    i18n = {
      defaultLocale = "en_GB.UTF-8";
      supportedLocales = [
        "en_GB.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
      ];
    };
  };
}
