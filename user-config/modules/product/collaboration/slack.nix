{ pkgs, lib, ... }:
# slack-desktop is x86_64-linux + darwin only; skip on aarch64-linux.
{
  home.packages =
    lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.slack) [ pkgs.slack ];
}
