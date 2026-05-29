{ pkgs, ... }:
# Azure CLI — not imported by the cloud bundle's default.nix. Import this
# leaf directly from a host config when I want it.
{
  home.packages = [
    pkgs.azure-cli
  ];
}
