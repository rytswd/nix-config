{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./git
    ./jujutsu
  ];

  vcs.git.enable = lib.mkDefault true;
  vcs.jujutsu.enable = lib.mkDefault true;
}
