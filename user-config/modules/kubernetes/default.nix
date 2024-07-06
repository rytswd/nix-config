{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./kubernetes.nix
    ./kubernetes-extra.nix
    ./cncf.nix
  ];

  kubernetes.basic.enable = lib.mkDefault true;
  kubernetes.extra.enable = lib.mkDefault false; # Being explicit
  kubernetes.cncf.enable = lib.mkDefault true;
}
