{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./swaylock-effects.nix
  ];

  lock-session.swaylock-effects.enable = lib.mkDefault true;
}
