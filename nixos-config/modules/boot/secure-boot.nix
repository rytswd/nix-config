{ pkgs, lib, config, ... }:
# UEFI Secure Boot. Not imported by the core boot bundle's default.nix --
# Secure Boot is host-specific (the machine has to be enrolled and the
# firmware put into setup mode first), so hosts opt in by importing this
# leaf directly.
#
# Bootloader coverage:
#   - Limine: fully wired here (sets `boot.loader.limine.secureBoot.enable`).
#   - systemd-boot: needs `lanzaboote` (separate flake input + its own module
#     wiring). Intentionally not done here -- add it alongside this leaf when
#     a host actually needs it.
#   - GRUB: out of scope.
#
# Initial setup (run once per machine, with firmware in Setup Mode):
#
#     sudo sbctl create-keys
#     sudo sbctl enroll-keys --microsoft   # keep MS keys for option ROMs / Windows
#     sudo sbctl verify                    # confirm everything signs cleanly
#
# After the first rebuild with this module enabled, re-enter UEFI and switch
# back from Setup Mode to User Mode (Secure Boot enabled).
#
# Persistence: `/var/lib/sbctl` holds the enrolled key material. On hosts
# using impermanence, ensure that path is persisted (see
# `nixos-config/modules/nix-impermanence.nix`).

{
  # `sbctl` is the userspace tool for managing Secure Boot keys and signing
  # EFI binaries. Useful regardless of which bootloader is in use, so install
  # it whenever this module is imported.
  environment.systemPackages = [ pkgs.sbctl ];

  # Limine has first-class Secure Boot support -- it self-signs its own EFI
  # files at build time using the keys under `/var/lib/sbctl`. Only flip the
  # option when Limine is actually the chosen bootloader; otherwise the
  # option doesn't exist and evaluation would fail.
  boot.loader.limine.secureBoot.enable = lib.mkIf config.boot.loader.limine.enable true;
}
