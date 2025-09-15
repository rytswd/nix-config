{ pkgs
, lib
, config
, ...}:

{
  options = {
    vpn.protonvpn.enable = lib.mkEnableOption "Enable ProtonVPN.";
  };

  config = lib.mkIf config.vpn.protonvpn.enable {
    home.packages = [
      pkgs.protonvpn-gui
      pkgs.protonvpn-cli
    ];
  };
}
