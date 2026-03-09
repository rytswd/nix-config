{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./git
    ./git/yubikey.nix
    ./jj
  ];

  vcs.git.enable = lib.mkDefault true;
  vcs.git.yubikey.enable = lib.mkDefault true;
  vcs.jj.enable = lib.mkDefault true;
}
