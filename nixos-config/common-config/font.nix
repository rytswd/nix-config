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
    ];
  };
}
