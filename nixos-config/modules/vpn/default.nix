{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./tailscale.nix
  ];

  vpn.tailscale.enable = lib.mkDefault true;
}
