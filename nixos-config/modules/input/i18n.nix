{ pkgs
, lib
, config
, ...}:

{
  options = {
    input.i18n.enable = lib.mkEnableOption "Enable i18n configuration.";
  };

  config = lib.mkIf config.input.i18n.enable {
    # Select internationalisation properties.
    i18n = {
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          # fcitx5-chinese-addons
        ];
      };
    };
  };
}
