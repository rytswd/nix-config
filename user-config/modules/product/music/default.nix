# Vendor music products. Bundle auto-imports the ones I want on every
# host; hosts that don't want them can drop the import or use
# `disabledModules` (see `nixos-config/mbp-utm/default.nix`).
{
  imports = [
    ./spotify.nix
    ./youtube-music.nix
  ];
}
