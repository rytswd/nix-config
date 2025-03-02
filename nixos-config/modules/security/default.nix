{ pkgs
, lib
, config
, ...}:

{
  imports = [
    # ./clamav.nix
  ];

  # NOTE: This used to be required for work.
  # security.clamav.enable = lib.mkDefault true;
}
