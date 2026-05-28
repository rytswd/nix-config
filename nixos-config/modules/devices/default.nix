{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./librepods.nix
    # NOTE: ./yubikey.nix is intentionally NOT imported here — host-specific.
  ];
}
