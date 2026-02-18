{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./brave.nix
    ./vivaldi.nix
    ./chromium.nix
    ./firefox.nix
    ./zen.nix
    # TODO: Nyxt build fails, and thus disabling it for now.
    # ./nyxt.nix
  ];

  # NOTE: The browsers are assumed to be the setup for NixOS. This is because
  # some of the packages are not packaged up for macOS.
  browser.brave.enable = lib.mkDefault true;
  browser.vivaldi.enable = lib.mkDefault true;
  # browser.chromium.enable = lib.mkDefault true;
  browser.firefox.enable = lib.mkDefault true;
  # browser.nyxt.enable = lib.mkDefault true;
  browser.zen.enable = lib.mkDefault true;
}
