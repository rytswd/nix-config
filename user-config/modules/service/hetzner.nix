{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.hetzner.enable = lib.mkEnableOption "Enable Hetzner related tooling.";
  };

  config = lib.mkIf config.service.hetzner.enable {
    home.packages = [
      pkgs.hcloud
    ];
  };
}
