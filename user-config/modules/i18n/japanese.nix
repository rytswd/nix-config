{ pkgs
, lib
, config
, ...}:

{
  options = {
    i18n.japanese.enable = lib.mkEnableOption "Enable Japanese.";
  };

  config = lib.mkIf config.i18n.japanese.enable {
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-configtool
          fcitx5-mozc
          fcitx5-gtk
          fcitx5-catppuccin
        ];
        settings = {
          # Corresponds to ~/.config/fcitx5/profile
          inputMethod = {
            GroupOrder = {
              "0" = "Main";
              "1" = "JP";
            };
            "Groups/0" = {
              Name = "Main";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us-dvorak";
            };
            "Groups/0/Items/0".Name = "keyboard-us-dvorak";

            "Groups/1" = {
              Name = "JP";
              "Default Layout" = "us";
              DefaultIM = "mozc";
            };
            "Groups/1/Items/0".Name = "mozc";
          };

          # Corresponds to ~/.config/fcitx5/conf/ directory
          addons = {
            quickphrase.globalSection = {
              TriggerKey = ""; # Disable this altogether.
              "Choose Modifier" = "None";
              Spell = true;
              FallbackSpellLanguage = "en";
            };
          };

          # Corresponds to ~/.config/fcitx5/config
          globalOptions = {
            Behavior = {
              ActiveByDefault = false;
            };
            "Hotkey/TriggerKeys" = {
              "0" = "F8";
            };
            "Hotkey/EnumerateGroupForwardKeys" = {
              "0" = "F9";
            };
            Hotkey = {
              EnumerateWithTriggerKeys = true;
              EnumerateSkipFirst = false;
              ModifierOnlyKeyTimeout = 250;
            };
          };
        };
      };
    };
  };
}
