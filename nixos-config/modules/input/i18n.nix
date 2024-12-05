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
    # TODO: Consider removing this
    # i18n = {
    #   inputMethod = {
    #     enable = true;
    #     type = "fcitx5";
    #     fcitx5.addons = with pkgs; [
    #       fcitx5-configtool
    #       fcitx5-mozc
    #       fcitx5-gtk
    #       # fcitx5-chinese-addons
    #     ];
    #   };
    # };
  };
}
