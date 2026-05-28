{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.librepods.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
