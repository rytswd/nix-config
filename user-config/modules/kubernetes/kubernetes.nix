{ pkgs
, lib
, config
, ...}:

{
  options = {
    kubernetes.basic.enable = lib.mkEnableOption "Enable basic tools for Kubernetes.";
    kubernetes.extra.enable = lib.mkEnableOption "Enable extra tools for Kubernetes, such as operating Kubernetes."
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
  config = lib.mkIf config.kubernetes.extra.enable {
    home.packages = [
      pkgs.talosctl
      pkgs.vcluster
    ];
  };
}
