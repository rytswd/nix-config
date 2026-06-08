# Trackpad preferences.
{ ... }:
{
  targets.darwin.defaults."com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
    Clicking = true;
  };
  targets.darwin.defaults."com.apple.AppleMultitouchTrackpad" = {
    Clicking = true;
  };
}
