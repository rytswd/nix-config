{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./sddm.nix
  ];

  display-manager.sddm.enable = lib.mkDefault true;
}
