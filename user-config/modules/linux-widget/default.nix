{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./network-manager.nix
    ./password.nix
  ];

  linux-widget.network-manager.enable = lib.mkDefault true;
}
