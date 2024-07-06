{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.firewall.dropbox.enable = lib.mkEnableOption "Enable firewall for Dropbox.";
  };

  config = lib.mkIf config.core.firewall.dropbox.enable {
    # Disable the firewall since we're in a VM and we want to make it
    # easy to visit stuff in here. We only use NAT networking anyways.
    # firewall.enable = false;
    networking.firewall = {
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
    };
  };
}
