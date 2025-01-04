{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./clipse
    ./wayland.nix
  ];

  clipboard.clipse.enable = lib.mkDefault true;
  # For Linux, enable by default.
  clipboard.wayland.enable = lib.mkDefault pkgs.stdenv.isLinux;
}
