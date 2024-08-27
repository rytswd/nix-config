{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./brave.nix
    ./vivaldi.nix
    ./nyxt.nix
    ./chromium.nix
  ];

  # NOTE: The browsers are assumed to be the setup for NixOS. This is because
  # some of the packages are not packaged up for macOS, and on macOS, I use
  # Arc Browser instead.
  browser.brave.enable = lib.mkDefault true;
  browser.vivaldi.enable = lib.mkDefault true;
  browser.nyxt.enable = lib.mkDefault true;
  # browser.chromium.enable = lib.mkDefault true;
}
