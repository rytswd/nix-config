{ pkgs, ... }:
{
  home.packages = [
    pkgs.mu
    pkgs.isync
    pkgs.msmtp
  ];
  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync -aVc ~/.config/isync/mbsyncrc";
    };
  };
}
