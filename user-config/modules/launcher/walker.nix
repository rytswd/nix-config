{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    launcher.walker.enable = lib.mkEnableOption "Enable Walker.";
  };

  config = lib.mkIf config.launcher.walker.enable {
    services.walker = {
      enable = true;
    };
  };
}
