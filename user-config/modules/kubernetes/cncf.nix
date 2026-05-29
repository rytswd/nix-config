{ pkgs, ... }:
{
  home.packages = [
    pkgs.kubeseal
    pkgs.pinniped
    pkgs.istioctl
    pkgs.cilium-cli
    pkgs.hubble
  ];
}
