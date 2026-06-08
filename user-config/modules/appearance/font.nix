# User-level fonts via Home Manager.
#
# Installed under `~/Library/Fonts/` on darwin and into the user's
# nix-profile on Linux. The Linux system-level font set
# (`nixos-config/modules/appearance/font.nix`) is independent and not
# overridden here, so importing both would only duplicate – import this
# one only on hosts that DON'T have the system-level fonts already.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.noto
    nerd-fonts.symbols-only
    nerd-fonts.victor-mono

    dejavu_fonts
    raleway
    monaspace
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    victor-mono
    emacs-all-the-icons-fonts

    # Fonts from Sora Sagano, clean and sophisticated look.
    # Ref: https://dotcolon.net
    tenderness
    medio
    melete
    seshat
    penna
    fa_1
    nacelle
    route159
  ];
}
