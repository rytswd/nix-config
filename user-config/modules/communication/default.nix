{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./email.nix
    ./slack.nix
    ./signal.nix
  ];

  communication.email.enable = lib.mkDefault true;
  communication.slack.enable = lib.mkDefault false; # Being explicit
  communication.signal.enable = lib.mkDefault false; # Being explicit
}
