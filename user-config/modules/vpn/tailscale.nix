{ pkgs
, lib
, config
, ...}:

{
  options = {
    vpn.tailscale.enable = lib.mkEnableOption "Enable Tailscale.";
  };

  config = lib.mkIf config.vpn.tailscale.enable {
    services.tailscale.enable = true;
    home.packages = [ pkgs.tailscale ];
  };
}
