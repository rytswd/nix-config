{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./network.nix
    ./firewall.nix
    ./shell.nix
    ./tools.nix
  ];

  core.network.enable = lib.mkDefault true;
  core.firewall.enable = lib.mkDefault true;
  core.shell.enable = lib.mkDefault true;
  core.tools.enable = lib.mkDefault true;
}
