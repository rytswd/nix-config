{
  pkgs,
  lib,
  config,
  ...
}:
# YubiKey support -- not imported by the devices bundle's default.nix. Import
# this leaf directly from a host config if the host actually has YubiKey.
let
  cfg = config.devices.yubikey;
in
{
  options.devices.yubikey.user = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "ryota";
    description = ''
      Linux user whose `--user` systemd instance should be poked when a
      YubiKey is plugged or unplugged (drives the home-manager unit
      `yk-git-update.service` declared in `user-config/modules/vcs/git/yubikey.nix`).
      Leave `null` to skip the hotplug udev rule entirely.
    '';
  };

  config = {
    environment.systemPackages = [
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.yubioath-flutter

      # age setup
      pkgs.age-plugin-yubikey
    ];

    # For PC and SC smart card reader daemon.
    services.pcscd.enable = true;
    # Ref: https://www.reddit.com/r/NixOS/comments/170tbbj/comment/k3okj79/
    services.udev.packages = [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];

    # Lock when the YubiKey is unplugged.
    # This works with YubiKey 5C NFC. It may need to be adjusted for other
    # models.
    #
    #     udevadm monitor --udev --environment
    #
    # Ref: https://nixos.wiki/wiki/Yubikey#Locking_the_screen_when_a_Yubikey_is_unplugged
    #
    # The second rule (when `devices.yubikey.user` is set) re-runs the user's
    # `yk-git-update.service` whenever any YubiKey is added/removed, so the
    # home-manager git signing config picks up the change.
    services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    ''
    + lib.optionalString (cfg.user != null) ''
      ACTION=="add|remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", \
          RUN+="${pkgs.systemd}/bin/machinectl shell --uid=${cfg.user} .host /bin/sh -c 'systemctl --user start yk-git-update.service || true'"
    '';

    # Enable U2F for login.
    #
    # Commands I can run to generate:
    #     nix shell nixpkgs#pam_u2f
    #
    #     # 1st YubiKey
    #     pamu2fcfg     > ~/.config/Yubico/u2f_keys
    #     # 2nd YubiKey
    #     pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
    #
    # Command to test:
    #     nix shell nixpkgs#pamtester
    #
    #     pamtester login ryota authenticate
    #     pamtester sudo  ryota authenticate
    #
    # Ref: https://nixos.wiki/wiki/Yubikey#pam_u2f
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      swaylock.u2fAuth = true;
    };

    security.pam = {
      u2f = {
        enable = true;
        settings.cue = true;
      };
    };

    # https://github.com/FiloSottile/yubikey-agent?tab=readme-ov-file
    # Because I am using GPG agent at the moment, I'm taking this out. There
    # seems to be some benefits for using yubikey-agent over gpg-agent. While I
    # am not fully comfortable with GPG, I got most of the settings working with
    # it. When yubikey-agent is in place, it takes hold of the lock for pcscd,
    # and thus disabling it.
    # services.yubikey-agent.enable = true;

    programs.yubikey-touch-detector = {
      enable = true;
    };

    # TODO: Check if this is necessary. Probably this is duplicating some other
    # settings (and I rely more on home-manager config anyways).
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
