{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./tailscale.nix
    ./protonvpn.nix
    # ./nordvpn.nix
  ];

  vpn.tailscale.enable = lib.mkDefault true;
  vpn.protonvpn.enable = lib.mkDefault true;
  # vpn.nordvpn.enable = lib.mkDefault true;
}
