{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./gdm.nix
    ./sddm.nix
    ./cosmic-greeter.nix
  ];

  login-manager.gdm.enable = lib.mkDefault false; # Being explicit
  login-manager.sddm.enable = lib.mkDefault true;
}
