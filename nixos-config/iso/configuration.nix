{ pkgs, lib, config, ... }:
{
  # Give custom image name
  image.baseName = lib.mkForce "nixos-rytswd-${config.system.nixos.release}-${pkgs.stdenv.hostPlatform.system}";

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

    # Secure Boot
    sbctl
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

  # Set default password of "nixos"
  users.users.nixos.initialHashedPassword = lib.mkForce "$6$EKMK91L2/xkLpFct$/2fWa9q0ZiSNYNZPWROp.3Jo1GIM8soMUlNYxsiSa9oOGiKo3y55IbkdqSXlNI3aICws5dxs8mLpn5oDqdBBw/";
}
