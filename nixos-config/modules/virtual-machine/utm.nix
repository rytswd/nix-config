{ lib, ... }:
# UTM-specific guest tweaks. NOT imported by the virtual-machine bundle's
# default.nix -- import this leaf directly when the host hypervisor is UTM.
#
# Assumes `nixos-config/modules/boot/systemd-boot.nix` (or another
# systemd-boot-providing leaf) is also imported -- this file only overrides
# the bits that UTM/QEMU specifically requires.
#
# Ref: https://docs.getutm.app/guest-support/linux/
{
  # SPICE WebDAV channel -- exposes the UTM host's "Shared Directory" as a
  # WebDAV endpoint inside the guest (consumable via `spice-webdavd` +
  # GVfs / `gio mount`). Cheap to enable; idles when no share is mounted.
  services.spice-webdavd.enable = true;

  # UTM/QEMU rejects any console-mode other than 0 with "error switching
  # console mode" during boot. Override the shared systemd-boot leaf's
  # `consoleMode = "auto"`.
  boot.loader.systemd-boot.consoleMode = lib.mkForce "0";

  # Apple Silicon + UTM's virtio-gpu has historically been flaky for
  # accelerated GL -- fall back to software rendering so Mesa/Wayland
  # don't trip on a half-working driver. Harmless on Intel hosts where
  # virtio-gpu is more reliable; drop once UTM's GL story stabilises.
  environment.sessionVariables.LIBGL_ALWAYS_SOFTWARE = "1";
}
