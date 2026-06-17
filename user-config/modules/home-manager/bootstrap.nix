{ config, ... }:
# Home-manager itself: bootstrap flags that govern how home-manager
# operates, rather than what gets installed.
{
  # Install the `home-manager` CLI into PATH so I can run inspection
  # commands like `home-manager generations` / `home-manager packages`
  # outside of `nixos-rebuild switch`. Activation works without it on a
  # NixOS-module setup, but the CLI is useful for ad-hoc inspection.
  programs.home-manager.enable = true;

  # `hm-switch` -- shorthand for re-applying the standalone HM profile
  # from anywhere. Points at `local.repoPath` (the nix-config checkout
  # that `home-git-clone` maintains under `local.ghRoot`), so the same
  # alias works on every host without quoting a flake ref. The flake's
  # `hm` app handles profile resolution, --impure, NIX_CONFIG and the
  # backup extension.
  # The flake ref is quoted so zsh (with EXTENDED_GLOB) does not treat `#`
  # as a glob operator when the alias expands.
  home.shellAliases.hm-switch = "nix run '${config.local.repoPath}#hm' -- switch";

  # Suppress the "Home Manager release X.YY does not match nixpkgs release
  # Y.ZZ" warning that fires at activation. I intentionally pin
  # home-manager and the system to different nixpkgs channels, so the
  # warning would fire on every `nixos-rebuild switch`.
  home.enableNixpkgsReleaseCheck = false;
}
