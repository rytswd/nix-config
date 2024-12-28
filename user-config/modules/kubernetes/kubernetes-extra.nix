{ pkgs
, lib
, config
, ...}:

{
  options = {
    kubernetes.extra.enable = lib.mkEnableOption "Enable extra tools for Kubernetes, such as operating Kubernetes.";
  };

  config = lib.mkIf config.kubernetes.extra.enable {
    home.packages = let
      mirrord = pkgs.callPackage ./mirrord/package.nix {};
    in [
      pkgs.talosctl
      pkgs.vcluster
      pkgs.kubevirt
      pkgs.kubelogin-oidc
      pkgs.mirrord
      # mirrord
    ];
  };
}
