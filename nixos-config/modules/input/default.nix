{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./trackpad.nix
  ];

  input.trackpad.enable = lib.mkDefault true;
}
