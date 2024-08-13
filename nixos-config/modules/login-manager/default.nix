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

  # TODO: I should adda a logic to ensure these options are mutually exclusive.
  login-manager.gdm.enable = lib.mkDefault false; # Being explicit
  login-manager.sddm.enable = lib.mkDefault true;
  login-manager.cosmic-greeter.enable = lib.mkDefault false; # Being explicit
}
