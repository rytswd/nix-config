{ pkgs
, lib
, config
, ...}:

{
  options = {
    vpn.tailscale.enable = lib.mkEnableOption "Enable ProtonVPN.";
  };

  config = lib.mkIf config.vpn.tailscale.enable {
    home.packages = [ pkgs.tailscale ];
  };
}
