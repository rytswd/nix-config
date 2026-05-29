{ pkgs, lib, ... }:
{
  imports = [
    ./clipse
  ] ++ lib.optional pkgs.stdenv.isLinux ./wayland.nix;
}
