{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./protonvpn.nix
    # ./nordvpn.nix
  ];

  # NOTE: Tailscale requires the systemd setup, which is set up using
  # services.tailscale.enable for both NixOS and macOS.

  vpn.protonvpn.enable = lib.mkDefault true;
  # vpn.nordvpn.enable = lib.mkDefault true;
}
