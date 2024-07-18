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
    home.shellAliases = {
      k = "kubectl";
      kgpa = "kubectl get pods -A";
    };
    home.sessionVariables = {
      KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";
    };
    xdg.configFile = {
      "kind".source = ./kind-config;
      "kind".recursive = true;
      "k9s/config.yaml".source = ./k9s/config.yaml;
      "k9s/aliases.yaml".source = ./k9s/aliases.yaml;
    };
  };
}
