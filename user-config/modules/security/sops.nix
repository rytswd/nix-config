{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = [
    pkgs.sops
  ];
  sops = {
    gnupg.home = "${config.xdg.configHome}/.gnupg";
  };
}
