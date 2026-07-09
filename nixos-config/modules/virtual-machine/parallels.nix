{ ... }:
# Parallels-specific guest tweaks. NOT imported by the virtual-machine
# bundle's default.nix -- import this leaf directly when the host
# hypervisor is Parallels Desktop (macOS).
#
# The sibling `common.nix` (qemu-guest profile + spice-vdagentd) is still
# fine to keep imported alongside this leaf: Parallels on Apple Silicon
# presents virtio devices too, and spice-vdagentd simply idles without a
# SPICE channel. Clipboard/display integration under Parallels comes from
# prl-tools (prlcc / prltoolsd) instead.
#
# Ref: nixpkgs nixos/modules/virtualisation/parallels-guest.nix
{
  # Parallels Tools for Linux guests -- shared folders (auto-mounted under
  # /mnt/psf since Parallels Desktop 20), clipboard sync, dynamic display
  # resolution, time sync (the module disables systemd-timesyncd in favour
  # of prltoolsd's own sync).
  # NOTE: `prl-tools` is unfree; `nixos-config/modules/nix-base.nix` already
  # sets `nixpkgs.config.allowUnfree = true` globally, so no extra
  # allowUnfreePredicate is needed here.
  hardware.parallels.enable = true;

  # Same rationale as the UTM leaf: accelerated GL for Linux ARM guests is
  # not reliably available (Parallels' 3D acceleration targets Windows /
  # x86 Linux), so fall back to software rendering rather than letting
  # Mesa/Wayland trip on a half-working driver. Drop once Parallels ships
  # working virtio-gpu GL for ARM Linux guests.
  environment.sessionVariables.LIBGL_ALWAYS_SOFTWARE = "1";

  # NOTE: Unlike UTM/QEMU, Parallels' UEFI has not shown the systemd-boot
  # "error switching console mode" issue, so consoleMode is left at the
  # shared leaf's default ("auto"). If boot logs ever complain, mirror the
  # `boot.loader.systemd-boot.consoleMode = lib.mkForce "0"` from utm.nix.
}
