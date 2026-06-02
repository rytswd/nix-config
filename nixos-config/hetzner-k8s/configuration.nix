{ 
  config,
  pkgs,
  lib,
  self,
  ...
}:

# Shared configuration for all Hetzner K8s nodes.
# Each node's default.nix imports this and sets hostName.

{
  imports = [
    "${self}/nixos-config/modules/core"
    "${self}/nixos-config/modules/kubernetes"

    # Hetzner Cloud specific overrides (BIOS boot, systemd-networkd, etc.)
    "${self}/nixos-config/modules/machine-specific/hetzner-cloud.nix"
  ];

  # --- Kubernetes modules ---
  # kubernetes.common keeps its `enable` flag (other tunables remain on the
  # module). The rest are now "imported = enabled" via the kubernetes bundle.
  kubernetes.common.enable = true;


  # --- Users ---
  # The admin user is created by the shared user-config module (imported
  # in each node's default.nix). Root login is via SSH key only.

  # --- Misc ---
  # NixOS release version for stateful data compatibility.
  system.stateVersion = "25.11";
}
