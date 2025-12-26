{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./zfs.nix
  ];

  core.zfs.enable = lib.mkDefault false; # Being explicit
}
