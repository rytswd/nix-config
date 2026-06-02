{ config, pkgs, ... }:
# spotify is x86_64-linux + darwin only.
{
  home.packages = config.local.availablePackages [ pkgs.spotify ];
}
