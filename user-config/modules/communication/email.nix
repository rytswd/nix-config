{ config, lib, pkgs, ... }:
{
  home.packages = [
    pkgs.mu
    pkgs.isync
    pkgs.msmtp
  ];

  # `programs.notmuch` asserts that at least one `accounts.email.accounts.<x>`
  # exists with `notmuch.enable = true` and has `realName` + `address` set.
  # Account definitions live outside this repo (e.g. `nix-config-private`'s
  # `homeManagerModules.email`). Defer enabling notmuch until at least one
  # account is actually configured — otherwise importing this bundle on a
  # host without the private email module trips the assertion (this is what
  # happens on darwin today).
  programs.notmuch = lib.mkIf (config.accounts.email.accounts != {}) {
    enable = true;
    hooks = {
      preNew = "mbsync -aVc ~/.config/isync/mbsyncrc";
    };
  };
}
