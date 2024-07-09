{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.signal.enable = lib.mkEnableOption "Enable Signal.";
  };

  config = lib.mkIf config.communication.signal.enable {
    home.packages = [ pkgs.signal-desktop ];
  };
}
