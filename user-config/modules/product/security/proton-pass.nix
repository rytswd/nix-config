{ pkgs, lib, ... }:
# proton-pass is built only for x86_64-linux + darwin; skip on aarch64-linux.
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.proton-pass) [ pkgs.proton-pass ];
}
