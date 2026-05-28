{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.gnumake
    pkgs.git
    pkgs.cachix
    pkgs.nh
    pkgs.nixos-rebuild-ng
  ];
}
