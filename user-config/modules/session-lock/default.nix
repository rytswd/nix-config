{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./swaylock-effects.nix
  ];

  session-lock.swaylock-effects.enable = lib.mkDefault true;
}
