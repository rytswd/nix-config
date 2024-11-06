{ pkgs
, lib
, config
, ...}:

{
  options = {
    vpn.tailscale.enable = lib.mkEnableOption "Enable Tailscale.";
  };

  config = lib.mkIf config.vpn.tailscale.enable {
    services.tailscale = {
      enable = true;
      # TODO: This is done by running the oneoff command via systemd, but does
      # not get rerun when rebuilding the system. There may be a better way to
      # handle this.
      extraSetFlags = [
        "--operator=ryota"
      ];
    };
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
