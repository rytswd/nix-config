{ pkgs
, lib
, config
, ...}:

{
  # Ref: https://wiki.archlinux.org/title/Input_remap_utilities

  # NOTE: Currently this is a noop module, and Xremap lives as a separate module
  # instead.
  # imports = [
  #   ./xremap.nix
  # ];

  # NOTE: Also, skhdrc is not included.

  # key-remap.xremap.enable = lib.mkDefault false;
}
