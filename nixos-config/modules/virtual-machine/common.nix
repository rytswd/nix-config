{ modulesPath, ... }:
# Base "this NixOS instance runs as a guest in a VM" setup that applies to
# any QEMU-flavoured hypervisor (plain QEMU/KVM, virt-manager, GNOME Boxes,
# UTM on macOS, …). Hypervisor-specific extras live in sibling leaves
# (e.g. ./utm.nix).
{
  imports = [
    # Adds virtio kernel modules (virtio_blk, virtio_scsi, virtio_net, …)
    # to the initrd. Without these, the kernel cannot find the root disk
    # on QEMU/KVM guests and the system will not boot.
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  # SPICE guest agent -- clipboard sync between host and guest, dynamic
  # display resize on host-window resize. Works whenever the host exposes
  # SPICE (QEMU `-spice`, UTM "Display: VirtIO-GPU + SPICE", virt-manager
  # default). Harmless on hosts that don't expose SPICE -- the agent just
  # idles waiting for a channel.
  services.spice-vdagentd.enable = true;
}
