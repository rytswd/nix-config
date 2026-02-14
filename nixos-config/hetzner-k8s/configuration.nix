{ 
  config,
  pkgs,
  lib,
  ...
}:

# Shared configuration for all Hetzner K8s nodes.
# Each node's default.nix imports this and sets hostName.

{
  imports = [
    ../modules/core
    ../modules/kubernetes

    # Hetzner Cloud specific overrides (BIOS boot, systemd-networkd, etc.)
    ../modules/machine-specific/hetzner-cloud.nix
  ];

  # --- Kubernetes modules: enable all ---
  kubernetes.common.enable     = true;
  kubernetes.containerd.enable = true;
  kubernetes.kubelet.enable    = true;
  kubernetes.kubeadm.enable    = true;
  kubernetes.networking.enable = true;

  # --- Core module overrides for headless server ---
  # Disable desktop-oriented defaults that don't apply to a K8s node.
  core.virtualisation.docker.enable = false;

  # --- Users ---
  # The admin user is created by the shared user-config module (imported
  # in each node's default.nix). Root login is via SSH key only.

  # --- Misc ---
  # NixOS release version for stateful data compatibility.
  system.stateVersion = "25.11";
}
