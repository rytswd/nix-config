{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./git.nix
  ];

  vcs.git.enable = lib.mkDefault true;
}
