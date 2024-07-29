{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./network-manager.nix
    ./bemoji.nix
    ./password.nix
  ];

  linux-widget.network-manager.enable = lib.mkDefault true;
  linux-widget.bemoji.enable = lib.mkDefault true;
  linux-widget.password.enable = lib.mkDefault true;
}
