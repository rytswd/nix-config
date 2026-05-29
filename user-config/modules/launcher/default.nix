{
  imports = [
    ./anyrun.nix
    ./fuzzel.nix
    ./rofi.nix
    ./walker.nix
    # NOTE: ./wofi.nix is intentionally NOT imported here — opt-in per host.
  ];
}
