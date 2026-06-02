{ config, lib, pkgs, ... }:
# https://www.passwordstore.org/
{
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };
  };

  # pass-secret-service is the D-Bus secret-service shim over pass; it's
  # intrinsically Linux-only (the macOS equivalent of `org.freedesktop.secrets`
  # is the system Keychain, not a separate provider). Platform-gate this so
  # importing `security/` from darwin doesn't trip home-manager's platform
  # assertion. See `nixos-config/modules/desktop-environment/gnome.nix` for
  # the matching NixOS-side handling that disables gnome-keyring.
  services.pass-secret-service.enable = lib.mkIf pkgs.stdenv.isLinux true;
}
