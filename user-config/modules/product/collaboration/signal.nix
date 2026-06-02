{ config, pkgs, ... }:
# signal-desktop has spotty aarch64-linux coverage upstream; skip on
# platforms where it isn't built.
{
  home.packages = config.local.availablePackages [ pkgs.signal-desktop ];
}
