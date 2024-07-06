{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.network.enable = lib.mkEnableOption "Enable network.";
  };

  config = lib.mkIf config.core.network.enable {
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
  };
}
