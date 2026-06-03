{
  imports = [
    ./bluetooth.nix
    ./keyboard.nix
    ./trackpad.nix
    # NOTE: ./librepods.nix, ./nvidia.nix, and ./yubikey.nix are intentionally
    # NOT imported here -- they're host-specific leaves (only the machines
    # that actually pair with AirPods / have an NVIDIA GPU / use a YubiKey
    # want them). Import directly from the host config.
  ];
}
