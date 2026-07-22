{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

# Because this module is specific to Asus machine, the import of this module would
# directly enable the Asus related configuration.

let
  pkgs-fast-track = import inputs.nixpkgs-unstable-fast-track {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{
  # NOTE: The config taken from:
  # https://asus-linux.org/guides/nixos/
  services.supergfxd.enable = true;
  services.asusd = {
    enable = true;
    # enableUserService = true;
  };
  services.asusd.package = pkgs-fast-track.asusctl.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [ ./aura_support-gz302ea.patch ];
  });
  programs.rog-control-center.enable = true;
}
