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

    # https://github.com/FiloSottile/yubikey-agent?tab=readme-ov-file
    # Because I am using GPG agent at the moment, I'm taking this out. There
    # seems to be some benefits for using yubikey-agent over gpg-agent. While I
    # am not fully comfortable with GPG, I got most of the settings working with
    # it. When yubikey-agent is in place, it takes hold of the lock for pcscd,
    # and thus disabling it.
    # services.yubikey-agent.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
