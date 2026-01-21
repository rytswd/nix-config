{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./git
    ./git/yubikey.nix
    ./jujutsu
  ];

  vcs.git.enable = lib.mkDefault true;
  vcs.git.yubikey.enable = lib.mkDefault true;
  vcs.jujutsu.enable = lib.mkDefault true;
}
