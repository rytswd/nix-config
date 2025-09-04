{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.locale.enable = lib.mkEnableOption "Enable locale settings.";
  };

  config = lib.mkIf config.core.locale.enable {
    # Set time zone based on the geo location.
    services.automatic-timezoned.enable = true;
    services.geoclue2 = {
      enable = true;
      enableDemoAgent = lib.mkForce true; # This might be the key missing piece
    };

    # Below sets the time zone statically when the location cannot be found.
    time.timeZone = lib.mkDefault "Europe/London";

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
