{ pkgs, lib, ... }:
# spotify is x86_64-linux + darwin only.
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.spotify) [ pkgs.spotify ];
}
