{ pkgs
, lib
, config
, ...}:

{
  options = {
    appearance.font.enable = lib.mkEnableOption "Enable additional fonts.";
  };

  config = lib.mkIf config.appearance.font.enable {
    fonts = {
      fontDir.enable = true;

      packages = [
        (pkgs.nerdfonts.override {
          fonts = [
            "DroidSansMono"
            "FiraCode"
            "FiraMono"
            "Hack"
            "Iosevka"
            "NerdFontsSymbolsOnly"
            "Noto"
          ]; })
      ] ++ [
        pkgs.raleway
        pkgs.monaspace
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk
        pkgs.noto-fonts-emoji
        pkgs.emacs-all-the-icons-fonts
      ];
    };
  };
}