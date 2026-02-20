{
  # GPG signing key ID (shared across all 4 YubiKeys)
  # Used for git commit signing when GPG is available
  # Full long-form key ID (without 0x prefix for Git compatibility)
  gpg-key-id = "6FF76B4830CBDB2E";

  # GPG-based SSH key (from YubiKey's GPG auth subkey, shared across all YubiKeys)
  # Used for SSH authentication when GPG is available
  gpg-ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILX+wxTLnIemOShAhsDgBpst0X/Ybu7SGZChaLSX/e7B";

  # FIDO2 resident keys - one auth + one signing key per YubiKey serial
  # Generated with: ssh-keygen -t ed25519-sk -O resident -C "YubiKey <serial> <purpose>"
  yubikey = {
    "28656036" = {
      auth = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIey7k133RLvHWG7AybBxK8la06QCKw5OGoxvi0IWqUaAAAACHNzaDpBdXRo yubikey-28656036-auth";
      sign = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDwOp5Hi95SJV+MzrwPXx+9si4DtKHPjjEVnCcfxxpimAAAADnNzaDpHaXRTaWduaW5n yubikey-28656036-signing";
    };
    "28656210" = {
      auth = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDjsRp17ZN3bBNsJzsS1UmXmztxnPChAIuM2sB8X47jvAAAACHNzaDpBdXRo yubikey-28656210-auth";
      sign = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINY7AcCZ8fpomi8xCrBzNuwOPrBVE+HNTXOdNqDzyuFZAAAADnNzaDpHaXRTaWduaW5n yubikey-28656210-signing";
    };
    "32149556" = {
      auth = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIObcjrmJ0U0y2K4WSTNP3s4iO3G+Jz4YmfiUPac++lMeAAAACHNzaDpBdXRo yubikey-32149556-auth";
      sign = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAcE4QrxQL58es6zCr/GxfGyzGgF5ykpan+mq+DlvK7MAAAADnNzaDpHaXRTaWduaW5n yubikey-32149556-signing";
    };
    "33200429" = {
      auth = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKb8IpultzzxnlcmL+DxNXNxMFWUBwIuyIiSY0EVwiRlAAAACHNzaDpBdXRo yubikey-33200429-auth";
      sign = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN08ypm/Dc7Ue6P3j25m0RdSavisMvUA6U7o+a0wAaEQAAAADnNzaDpHaXRTaWduaW5n yubikey-33200429-signing";
    };
  };
}
