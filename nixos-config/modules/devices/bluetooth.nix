{ pkgs
, lib
, config
, ...}:

{
  options = {
    devices.bluetooth.enable = lib.mkEnableOption "Enable bluetooth.";
  };

  config = lib.mkIf config.devices.bluetooth.enable {
    # For bluetooth manager GUI
    services.blueman.enable = true;
  };
}
