{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./common.nix # No flag to enable / disable

    ./grub.nix
    ./limine.nix
    ./systemd-boot.nix
  ];

  # Explicitly disabling all. Only one can be enabled at a time.
  core.boot.limine.enable = lib.mkDefault false;
  core.boot.grub.enable = lib.mkDefault false;
  core.boot.systemd-boot.enable = lib.mkDefault false;
}
