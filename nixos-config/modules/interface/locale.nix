{ config, pkgs, ... }:

{
    # Define your hostname.
    networking.hostName = "dev";

    # Set your time zone.
    time.timeZone = "Europe/London";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";
}
