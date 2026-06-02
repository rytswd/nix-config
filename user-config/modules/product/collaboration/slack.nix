{ config, pkgs, ... }:
# slack-desktop is x86_64-linux + darwin only; skip on aarch64-linux.
{
  home.packages = config.local.availablePackages [ pkgs.slack ];
}
