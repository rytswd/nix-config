{ pkgs, inputs, ... }:
# AGS-based notification handling. Not imported by the bundle's default.nix;
# import this leaf directly from a host config when I want it.
{
  home.packages = [
    inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  xdg.configFile = {
    "ags-notification".source = ./ags-notification;
    "ags-notification".recursive = true;
  };
}
