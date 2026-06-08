# Dock preferences.
{ ... }:
{
  targets.darwin.defaults."com.apple.dock" = {
    autohide     = true;
    showhidden   = true;
    show-recents = false;
    orientation  = "bottom"; # changing this requires a logout/login

    # Hot corners. 1 = Disabled, 10 = Display sleep, 13 = Lock screen.
    wvous-tl-corner = 10; # Top-left:     sleep display
    wvous-tr-corner = 1;  # Top-right:    disabled
    wvous-bl-corner = 13; # Bottom-left:  lock screen
    wvous-br-corner = 1;  # Bottom-right: disabled
  };
}
