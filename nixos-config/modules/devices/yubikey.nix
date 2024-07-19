{ pkgs
, lib
, config
, ...}:

{
  options = {
    devices.yubikey.enable = lib.mkEnableOption "Enable YubiKey.";
  };

  config = lib.mkIf config.devices.yubikey.enable {
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.yubikey-agent.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
