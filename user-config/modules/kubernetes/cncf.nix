{ pkgs
, lib
, config
, ...}:

{
  options = {
    kubernetes.cncf.enable = lib.mkEnableOption "Enable CNCF Project related items.";
  };

  config = lib.mkIf config.kubernetes.cncf.enable {
    home.packages = [
      pkgs.kubeseal
      pkgs.pinniped
      pkgs.istioctl
      pkgs.cilium-cli
      pkgs.hubble
    ];
  };
}
