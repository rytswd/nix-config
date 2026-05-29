{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.sox
  ];
}
