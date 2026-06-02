# NOTE: The browsers are assumed to be the setup for NixOS. This is because
# some of the packages are not packaged up for macOS.
{
  imports = [
    ./brave.nix
    ./vivaldi.nix
    ./firefox.nix
    ./zen.nix
    # NOTE: ./chromium.nix and ./nyxt.nix are opt-in -- import directly from
    # the host config when needed. nyxt build is currently broken.
  ];
}
