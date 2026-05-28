{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./librepods.nix
    ./trackpad.nix
    # NOTE: ./nvidia.nix and ./yubikey.nix are intentionally NOT imported
    # here — they're host-specific hardware leaves (import directly).
  ];
}
