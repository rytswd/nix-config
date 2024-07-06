{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./shell.nix
  ];

  core.shell.enable = lib.mkDefault true;
}
