# NSGlobalDomain user preferences.
{ ... }:
{
  targets.darwin.defaults.NSGlobalDomain = {
    # Fastest key repeat. Effectively required for vim/emacs muscle memory.
    InitialKeyRepeat = 15;
    KeyRepeat        = 1;

    # Disable text "helpers" that fight typing.
    NSAutomaticCapitalizationEnabled     = false;
    NSAutomaticPeriodSubstitutionEnabled = false;

    # F-keys as F-keys, not media keys.
    "com.apple.keyboard.fnState" = true;

    # Beep volume – quieter is nicer.
    "com.apple.sound.beep.volume" = 0.25;
  };
}
