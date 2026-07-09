# Base "this NixOS instance is a VM guest" setup. Hypervisor-specific
# extras (UTM, Parallels, ...) are opt-in leaves that hosts import directly.
{
  imports = [
    ./common.nix
    # NOTE: ./utm.nix and ./parallels.nix are intentionally NOT imported
    # here -- hosts import the leaf matching their hypervisor directly.
    # Add other hypervisor leaves (e.g. ./vmware.nix) here as siblings
    # if/when needed.
  ];
}
