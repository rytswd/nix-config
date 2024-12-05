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
      enabled = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-configtool
          fcitx5-mozc
          fcitx5-gtk
          fcitx5-catppuccin
        ];
      };
    };
  };
}
