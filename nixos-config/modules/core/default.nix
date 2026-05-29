# Truly cross-host system config. Anything specific to a workstation/laptop
# environment (NetworkManager, geoclue + locale, docker stack, nix-ld,
# system gpg-agent, Dropbox firewall, xremap uinput rule) lives in
# `../workstation` instead so headless hosts don't drag it in.
{
  imports = [
    ./shell.nix
    ./ssh.nix
    ./sudo.nix
    ./tmp.nix
    ./tools.nix
    ./user-management.nix
  ];
}
