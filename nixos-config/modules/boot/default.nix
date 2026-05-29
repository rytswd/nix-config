# Bootloaders are mutually exclusive — the bundle only imports common.nix
# (shared boot.loader setup). Hosts pick one of ./grub.nix, ./limine.nix,
# ./systemd-boot.nix and import it directly.
{
  imports = [
    ./common.nix
  ];
}
