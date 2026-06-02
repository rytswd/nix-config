{ config, ... }:
# WireGuard -- not imported by the vpn bundle's default.nix. Import this leaf
# directly from a host config when I want it.
{
  networking.wireguard.interfaces = {
    wg0 = {
      # The local IP address for the WireGuard interface.
      # Adjust to match my WireGuard network.
      ips = [ "10.0.0.2/24" ];

      # Use the sops-nix managed secret file for the private key.
      privateKeyFile = "${config.xdg.configHome}/wireguard/key";

      # The UDP port WireGuard listens on.
      listenPort = 51820;

      peers = [
        {
          # rytswd-hetzner-lab
          allowedIPs = [ "10.100.0.1/32" ];
          publicKey = "vEbPj9DTkdqm9RAstLbCohe9fi3RMpNH/kOI5u1vn2A=";
        }
        {
          # phone
          allowedIPs = [ "10.100.0.3/32" ];
          publicKey = "q/tHX4F4F/4nq6d/B4MULNbm0klkmStCGtBGJ9uDZG4=";
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
