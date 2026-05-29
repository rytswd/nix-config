# Base "this NixOS instance is a VM guest" setup. Hypervisor-specific
# extras (UTM, …) are opt-in leaves that hosts import directly.
{
  imports = [
    ./common.nix
    # NOTE: ./utm.nix is intentionally NOT imported here — hosts running
    # under UTM import the leaf directly. Add other hypervisor leaves
    # (e.g. ./vmware.nix) here as siblings if/when needed.
  ];
}
