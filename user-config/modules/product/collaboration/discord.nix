{ pkgs, ... }:
# On Linux, always Vesktop (better Wayland support than the official client,
# and broader platform coverage -- official Discord is x86_64-only on Linux,
# Vesktop builds on aarch64 too). On Darwin, the official Discord client.
{
  home.packages = [
    (if pkgs.stdenv.isDarwin then pkgs.discord else pkgs.vesktop)
  ];
}
