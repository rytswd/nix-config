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
        pkgs.dejavu_fonts
        pkgs.raleway
        pkgs.monaspace
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk
        pkgs.noto-fonts-emoji
        pkgs.emacs-all-the-icons-fonts

        # Fonts from Sora Sagano, clean and sophisticated look
        # Ref: https://dotcolon.net
        pkgs.tenderness
        pkgs.medio
        pkgs.melete
        pkgs.seshat
        pkgs.penna
        pkgs.fa_1
        pkgs.nacelle
        pkgs.route159
      ];
    };
  };
}
