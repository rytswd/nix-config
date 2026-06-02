{ config, pkgs, ... }:
{
  home.packages = config.local.availablePackages [ pkgs.keybase ];
}
