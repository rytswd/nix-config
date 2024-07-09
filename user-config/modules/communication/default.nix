{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./slack.nix
    ./signal.nix
  ];

  communication.slack.enable = lib.mkDefault false; # Being explicit
  communication.signal.enable = lib.mkDefault false; # Being explicit
}
