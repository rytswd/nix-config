{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    devices.librepods.enable = lib.mkEnableOption "Enable LibrePods to use AirPods.";
  };

  config = lib.mkIf config.devices.librepods.enable {
    environment.systemPackages = [
      inputs.librepods.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
