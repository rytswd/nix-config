{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./network.nix
    ./firewall.nix
    ./shell.nix
    ./ssh.nix
    ./gnupg.nix
    ./tools.nix
    ./user-management.nix
    ./virtualisation.nix
  ];

  core.network.enable = lib.mkDefault true;
  core.firewall.dropbox.enable = lib.mkDefault true;
  core.shell.enable = lib.mkDefault true;
  core.ssh.enable = lib.mkDefault true;
  core.gnupg.enable = lib.mkDefault true;
  core.tools.enable = lib.mkDefault true;
  core.virtualisation.docker.enable = lib.mkDefault true;
  core.user-management.enable = lib.mkDefault true;
}
