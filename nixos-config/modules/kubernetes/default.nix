{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./common.nix
    ./containerd.nix
    ./kubelet.nix
    ./kubeadm.nix
    ./networking.nix
  ];

  kubernetes.common.enable      = lib.mkDefault false;
  kubernetes.containerd.enable  = lib.mkDefault false;
  kubernetes.kubelet.enable     = lib.mkDefault false;
  kubernetes.kubeadm.enable     = lib.mkDefault false;
  kubernetes.networking.enable  = lib.mkDefault false;
}
