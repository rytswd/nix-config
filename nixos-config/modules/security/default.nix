{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./clamav.nix
  ];

  # NOTE: This is required for the work environment.
  security.clamav.enable = lib.mkDefault true;
}
