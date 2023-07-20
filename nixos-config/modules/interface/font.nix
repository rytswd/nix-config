{ pkgs, ...}:

{
  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      fira
      fira-code
      fira-code-symbols
      nerdfonts
      powerline-fonts
    ];
  };
}
