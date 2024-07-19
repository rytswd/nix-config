{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.udev.enable = lib.mkEnableOption "Enable udev extra config.";
  };

  config = lib.mkIf config.core.udev.enable {
    hardware.uinput.enable = true;
    services.udev = {
      # NOTE: Xremap requires the following:
      # https://github.com/xremap/xremap?tab=readme-ov-file#running-xremap-without-sudo
      extraRules = ''
        KERNEL=="uinput", GROUP="input", TAG+="uaccess"
      '';
    };
  };
}
