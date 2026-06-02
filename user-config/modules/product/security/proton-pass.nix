{ config, pkgs, ... }:
# proton-pass is built only for x86_64-linux + darwin; skip on aarch64-linux.
{
  home.packages = config.local.availablePackages [ pkgs.proton-pass ];
}
