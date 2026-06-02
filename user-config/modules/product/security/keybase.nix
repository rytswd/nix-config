{ pkgs, lib, ... }:
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.keybase) [ pkgs.keybase ];
}
