{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./git.nix
    ./jujutsu.nix
  ];

  vcs.git.enable = lib.mkDefault true;
  vcs.jujutsu.enable = lib.mkDefault true;
}
