# Home Manager module flake outputs.
#
# Lists what gets exposed as `<flake>.homeModules.<name>`. Adding a new
# module file does NOT automatically expose it -- add a line below.
# Commenting / removing a line hides the module from downstream consumers.
#
# We list bundles + helpers only. Sub-features within a bundle are
# reachable via their bundle's `mkEnableOption` flags -- consumers import
# the bundle and toggle what they want, so there's no need to expose
# every leaf as a separate flake output.
#
# Paths are resolved relative to this file.
{
  ###----------------------------------------
  ##   Helpers
  #------------------------------------------
  # Home-manager bootstrap (CLI install + release-check suppression).
  home-manager    = ./home-manager;
  # Shared option declarations like `local.repoPath`.
  lib-paths       = ./lib/paths.nix;

  ###----------------------------------------
  ##   Bundles
  #------------------------------------------
  appearance      = ./appearance;
  darwin-defaults = ./darwin-defaults;

  ###----------------------------------------
  ##   Standalone (cross-platform-relevant)
  #------------------------------------------
  # Fonts via HM – useful on darwin where there's no NixOS system-level
  # font module to take care of it. Linux hosts already get fonts from
  # `nixos-config/modules/appearance/font.nix` at system level.
  appearance-font = ./appearance/font.nix;
  browser         = ./browser;
  clipboard       = ./clipboard;
  communication   = ./communication;
  dictionary      = ./dictionary;
  editor          = ./editor;
  file-management = ./file-management;
  i18n            = ./i18n;
  image           = ./image;
  key-remap       = ./key-remap;
  kubernetes      = ./kubernetes;
  launcher        = ./launcher;
  linux-widget    = ./linux-widget;
  llm             = ./llm;
  music           = ./music;
  notification    = ./notification;
  process         = ./process;
  programming     = ./programming;
  screenshot      = ./screenshot;
  security        = ./security;
  shell           = ./shell;
  terminal        = ./terminal;
  vcs             = ./vcs;
  video           = ./video;
  virtualisation  = ./virtualisation;
  vpn             = ./vpn;
}
