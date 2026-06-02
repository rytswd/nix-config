# NixOS module flake outputs.
#
# Lists what gets exposed as `<flake>.nixosModules.<name>`. Adding a new
# module file does NOT automatically expose it — add a line below.
# Commenting / removing a line hides the module from downstream consumers.
#
# We list bundles + standalone modules only. Sub-features (e.g. core/ssh.nix,
# kubernetes/common.nix) are reachable via their bundle's `mkEnableOption`
# flags — consumers import the bundle and toggle what they want, so there's
# no need to expose every leaf as a separate flake output.
#
# Paths are resolved relative to this file.
{
  ###----------------------------------------
  ##   Standalone top-level modules
  #------------------------------------------
  nix-base                  = ./nix-base.nix;
  nix-impermanence          = ./nix-impermanence.nix;

  ###----------------------------------------
  ##   Bundles
  #------------------------------------------
  appearance                = ./appearance;
  boot                      = ./boot;
  core                      = ./core;
  desktop-environment       = ./desktop-environment;
  devices                   = ./devices;
  flatpak                   = ./flatpak;
  graphics                  = ./graphics;
  kubernetes                = ./kubernetes;
  media                     = ./media;
  security                  = ./security;
  virtual-machine           = ./virtual-machine;
  vpn                       = ./vpn;
  window-manager            = ./window-manager;
  workstation               = ./workstation;

  ###----------------------------------------
  ##   machine-specific
  #------------------------------------------
  # No bundle default.nix here; standalone modules only, kept exposed
  # because consumers with the same hardware can borrow them directly.
  machine-specific-asus           = ./machine-specific/asus.nix;
  machine-specific-asus-webcam    = ./machine-specific/asus-webcam.nix;
  machine-specific-hetzner-cloud  = ./machine-specific/hetzner-cloud.nix;
  machine-specific-laptop         = ./machine-specific/laptop.nix;
}
