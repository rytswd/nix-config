# nix-darwin module flake outputs.
#
# Per-cask modules under `<category>/<cask>.nix` are intentionally NOT
# exposed here -- they're personal homebrew preferences, not a public
# API. Hosts import them directly from `${self}/macos-config/modules/...`
# as needed.
{
  nix-base = ./nix-base.nix;
  homebrew = ./homebrew.nix;
  security = ./security.nix;
}
