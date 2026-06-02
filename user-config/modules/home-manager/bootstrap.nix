{ ... }:
# Home-manager itself: bootstrap flags that govern how home-manager
# operates, rather than what gets installed.
{
  # Install the `home-manager` CLI into PATH so I can run inspection
  # commands like `home-manager generations` / `home-manager packages`
  # outside of `nixos-rebuild switch`. Activation works without it on a
  # NixOS-module setup, but the CLI is useful for ad-hoc inspection.
  programs.home-manager.enable = true;

  # Suppress the "Home Manager release X.YY does not match nixpkgs release
  # Y.ZZ" warning that fires at activation. I intentionally pin
  # home-manager and the system to different nixpkgs channels, so the
  # warning would fire on every `nixos-rebuild switch`.
  home.enableNixpkgsReleaseCheck = false;
}
