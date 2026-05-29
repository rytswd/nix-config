{ pkgs, ... }:
{
  home.packages = [
    pkgs.qemu
    pkgs.virt-manager
    pkgs.virt-viewer
  ];
}
