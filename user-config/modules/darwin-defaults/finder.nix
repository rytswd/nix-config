# Finder preferences.
{ ... }:
{
  targets.darwin.defaults."com.apple.finder" = {
    AppleShowAllFiles      = true;
    AppleShowAllExtensions = true;
    QuitMenuItem           = true;
    ShowPathbar            = true;

    FXEnableExtensionChangeWarning = false;
    FXPreferredViewStyle           = "Nlsv"; # List view
  };
}
