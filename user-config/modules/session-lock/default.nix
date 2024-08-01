{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./swayidle.nix
    ./swaylock-effects.nix
  ];

  session-lock.swayidle.enable = lib.mkDefault true;
  session-lock.swaylock-effects.enable = lib.mkDefault true;
}
