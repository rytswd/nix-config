{ pkgs
, lib
, config
, ...}:

{
  options = {
    virtual-machine.spice.enable = lib.mkEnableOption "Enable SPICE agent.";
  };

  config = lib.mkIf config.virtual-machine.spice.enable {
    services = {
      # SPICE agent needed for screen resize handling, clipboard, etc.
      # Ref: https://docs.getutm.app/guest-support/linux/#spice-agent
      spice-vdagentd.enable = true;
    };
  };
}
