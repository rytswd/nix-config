{ pkgs, ... }:

{
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
    ];
  };
}
