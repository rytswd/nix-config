# Cluster-level constants for the Hetzner K8s deployment.

export const LOCATION    = "nbg1"
export const SERVER_TYPE = "cx33"
export const IMAGE       = "ubuntu-24.04"

export const NODES = [
  "hetzner-k8s-cp-1"
  "hetzner-k8s-cp-2"
  "hetzner-k8s-cp-3"
]

export const POD_SUBNET     = "10.244.0.0/16"
export const SERVICE_SUBNET = "10.96.0.0/12"
export const CILIUM_VERSION = "1.18.7"

# Capture this file's directory at parse time so path resolution
# works regardless of the caller's working directory.
const SELF      = path self
const SELF_DIR  = ($SELF | path dirname)
# Repository root: lib/ → hetzner-k8s/ → nixos-config/ → repo root
const REPO_ROOT = ($SELF_DIR | path join "../../.." | path expand)

# Return the repository root (where flake.nix lives).
export def flake-root [] {
  $REPO_ROOT
}

# Read the Kubernetes version from the Nix flake.
# This is the single source of truth — defined in modules/kubernetes/common.nix.
export def k8s-version [] {
  let v = (nix eval --raw $"($REPO_ROOT)#nixosConfigurations.($NODES.0).config.kubernetes.common.version")
  $"v($v)"
}
