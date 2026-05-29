# NOTE: Tailscale requires the systemd setup, which is set up using
# services.tailscale.enable for both NixOS and macOS.
{
  imports = [
    ./protonvpn.nix
    # ./nordvpn.nix
  ];
}
