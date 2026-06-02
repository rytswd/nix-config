{ pkgs, ... }:
# Extra tooling for operating Kubernetes clusters (vs. just talking to one).
# Not imported by the kubernetes bundle's default.nix -- opt-in per host.
{
  home.packages = [
    pkgs.talosctl
    pkgs.vcluster
    pkgs.kubevirt
    pkgs.kubelogin-oidc
    pkgs.mirrord
  ];
}
