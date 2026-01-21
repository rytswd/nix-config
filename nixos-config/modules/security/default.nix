{ pkgs
, lib
, config
, ...}:

{
  imports = [
    # ./clamav.nix
    ./pam.nix
  ];

  # NOTE: This used to be required for work.
  # security.clamav.enable = lib.mkDefault true;
  security.pam.enable = lib.mkDefault true;
}
