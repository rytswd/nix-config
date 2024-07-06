{ pkgs
, lib
, config
, ...}:

{
  options = {
    virtual-machine.misc.enable = lib.mkEnableOption "Enable other misc VM specific settings.";
  };

  config = lib.mkIf config.virtual-machine.misc.enable {
    environment = {
      # For now, we need this since hardware acceleration does not work.
      variables.LIBGL_ALWAYS_SOFTWARE = "1";
    };
  };
}
