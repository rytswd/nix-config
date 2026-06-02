{ pkgs, lib, ... }:
# telegram-desktop + tg cover x86_64/aarch64 Linux and darwin; gate
# defensively so a future platform-coverage regression doesn't break
# eval for hosts that don't actually need the package.
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.telegram-desktop) [ pkgs.telegram-desktop ]
    ++ lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.tg) [ pkgs.tg ];
}
