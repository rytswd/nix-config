{ pkgs, lib, ... }:
# signal-desktop has spotty aarch64-linux coverage upstream; skip the
# install on platforms where it isn't built.
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.signal-desktop) [ pkgs.signal-desktop ];
}
