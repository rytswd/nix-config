{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./brave.nix
    ./vivaldi.nix
    ./chromium.nix
  ];

  browser.brave.enable = lib.mkDefault true;
  browser.vivaldi.enable = lib.mkDefault true;
  # browser.chromium.enable = lib.mkDefault true;
}
