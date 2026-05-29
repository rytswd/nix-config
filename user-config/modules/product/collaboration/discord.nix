{ pkgs, ... }:
# On Linux, prefer Vesktop — the official Discord client has poorer Wayland
# support. On macOS, just use the official client.
{
  home.packages = [
    (if pkgs.stdenv.isDarwin then pkgs.discord else pkgs.vesktop)
  ];
}
