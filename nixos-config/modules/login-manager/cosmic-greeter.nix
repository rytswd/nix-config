{ pkgs
, lib
, config
, ...}:

{
  options = {
    login-manager.cosmic-greeter.enable = lib.mkEnableOption "Enable COSMIC Greeter.";
  };

  config = lib.mkIf config.login-manager.cosmic-greeter.enable {
    # services.displayManager.cosmic-greeter.enable = true;
  };
}
