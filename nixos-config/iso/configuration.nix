{ pkgs, ... }:
{
  # ── YubiKey + SOPS tooling ──
  environment.systemPackages = with pkgs; [
    # Age encryption with YubiKey
    age
    age-plugin-yubikey
    sops

    # Smart card / YubiKey utilities
    yubikey-manager
    yubikey-personalization
    ccid

    # General tooling useful during install
    git
    nushell
    rsync
    neovim
  ];

  # pcscd is required for YubiKey communication
  services.pcscd.enable = true;

  # Ensure the CCID driver is picked up automatically
  # (avoids the manual PCSCLITE_HP_DROPDIR trick from your README)
  services.pcscd.plugins = [ pkgs.ccid ];

  # Enable flakes on the live ISO
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  # Optional: networking helpers
  networking.wireless.enable = false; # We use NetworkManager instead
  networking.networkmanager.enable = true;
}
