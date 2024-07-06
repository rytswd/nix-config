{ pkgs
, lib
, config
, ...}:

{
  options = {
    kubernetes.basic.enable = lib.mkEnableOption "Enable basic tools for Kubernetes.";
  };

  config = lib.mkIf config.kubernetes.basic.enable {
    home.packages = [
      pkgs.kubectl
      pkgs.kustomize
      pkgs.kubernetes-helm
      pkgs.kind
      pkgs.krew
      pkgs.k9s
      pkgs.kube3d
      pkgs.kubectx
    ];
  };
}
