{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./zfs.nix
  ];

  filesystem.zfs.enable = lib.mkDefault false; # Being explicit
}
