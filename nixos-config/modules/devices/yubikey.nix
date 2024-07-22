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
    services.yubikey-agent.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
