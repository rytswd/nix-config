{ pkgs
, lib
, config
, ...}:

{
  options = {
    devices.yubikey.enable = lib.mkEnableOption "Enable YubiKey.";
  };

  config = lib.mkIf config.devices.yubikey.enable {
    environment.systemPackages = [
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.yubioath-flutter
    ];

    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    # Lock when the YubiKey is unplugged.
    # This works with YubiKey 5C NFC. It may need to be adjusted for other
    # models.
    #
    # Ref: https://nixos.wiki/wiki/Yubikey#Locking_the_screen_when_a_Yubikey_is_unplugged
    services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
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

    # https://github.com/FiloSottile/yubikey-agent?tab=readme-ov-file
    # Because I am using GPG agent at the moment, I'm taking this out. There
    # seems to be some benefits for using yubikey-agent over gpg-agent. While I
    # am not fully comfortable with GPG, I got most of the settings working with
    # it. When yubikey-agent is in place, it takes hold of the lock for pcscd,
    # and thus disabling it.
    # services.yubikey-agent.enable = true;

    # TODO: Check if this is necessary. Probably this is duplicating some other
    # settings (and I rely more on home-manager config anyways).
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
