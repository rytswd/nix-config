# Firewall rules to allow Dropbox LAN sync (TCP/UDP 17500).
{
  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };
}
