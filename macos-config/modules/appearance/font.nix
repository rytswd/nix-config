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
      # TODO: Probably not needed for macOS?
      # fontDir.enable = true;

      packages = [
        pkgs.nerd-fonts.droid-sans-mono
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.fira-mono
        pkgs.nerd-fonts.hack
        pkgs.nerd-fonts.iosevka
        pkgs.nerd-fonts.noto
        pkgs.nerd-fonts.symbols-only
        pkgs.nerd-fonts.victor-mono

        pkgs.dejavu_fonts
        pkgs.raleway
        pkgs.monaspace
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-emoji
        pkgs.victor-mono
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
