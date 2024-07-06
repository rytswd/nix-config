{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./basic.nix
    ./cncf.nix
  ];

  kubernetes.basic.enable = lib.mkDefault true;
  kubernetes.extra.enable = lib.mkDefault false; # Being explicit
  kubernetes.cncf.enable = lib.mkDefault true;
}
