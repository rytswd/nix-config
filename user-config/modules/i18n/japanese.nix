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
          fcitx5-mozc
          fcitx5-gtk
        #   fcitx5-configtool
        ];

        settings = {
          # Corresponds to ~/.config/fcitx5/profile
          inputMethod = {
            GroupOrder = {
              "0" = "Main";
              "1" = "JP";
            };

            # Main keyboard layout which is US Dvorak
            "Groups/0" = {
              Name = "Main";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us-dvorak";
            };
            "Groups/0/Items/0".Name = "keyboard-us-dvorak";

            # Keyboard layout for Japanese typing
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

        # Corresponds to ~/.local/share/fcitx5/themes/ directory
        themes = {
          mocha = let
            catppuccinThemes = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "fcitx5";
              rev = "393845cf3ed0e0000bfe57fe1b9ad75748e2547f";
              hash = "sha256-ss0kW+ulvMhxeZKBrjQ7E5Cya+02eJrGsE4OLEkqKks=";
            };
            catppuccinTheme = "${catppuccinThemes}/src/catppuccin-mocha-mauve";
          in {
            # theme = ./theme.conf;
            theme = (builtins.readFile "${catppuccinTheme}/theme.conf");
            highlightImage = "${catppuccinTheme}/highlight.svg";
            panelImage = "${catppuccinTheme}/panel.svg";
          };
        };
        # Based on the above theem name, enable it with the below addon config.
        settings.addons.classicui.globalSection.Theme = "mocha";
      };
    };
  };
}
