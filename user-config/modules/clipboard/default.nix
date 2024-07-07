{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./wayland.nix
  ];

  # For Linux, enable by default.
  clipboard.wayland.enable = lib.mkDefault pkgs.stdenv.isLinux;
}
