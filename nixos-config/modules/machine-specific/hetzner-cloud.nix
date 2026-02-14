{ pkgs
, lib
, config
, modulesPath
, ...}:

# Hetzner Cloud VM overrides. Standard CX-line VMs use BIOS boot (not EFI)
# and a single NIC with DHCP provided by Hetzner's network. Import this
# module in any Hetzner Cloud NixOS configuration.

{
  imports = [
    # Adds virtio kernel modules (virtio_blk, virtio_scsi, virtio_net, etc.)
    # to the initrd. Without these, the kernel cannot find the root disk
    # on QEMU/KVM guests and the system will not boot.
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  # --- Boot: hybrid BIOS + EFI via GRUB ---
  # Hetzner Cloud VMs may boot via either BIOS or UEFI depending on the
  # generation. A hybrid setup (EF02 + ESP partitions in disko, GRUB with
  # efiSupport + efiInstallAsRemovable) works under both firmware types.
  # This matches the official nixos-anywhere Hetzner example.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # device is set automatically by disko from the EF02 (BIOS boot) partition.
  };
  # efiInstallAsRemovable puts the EFI binary at the fallback path
  # (/EFI/BOOT/BOOTX64.EFI) instead of using efibootmgr, so we don't
  # need canTouchEfiVariables (and cloud VMs often can't persist them).
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # --- Networking: systemd-networkd, not NetworkManager ---
  # Headless servers have no use for NetworkManager. core/network.nix
  # enables it by default, so we force it off and use systemd-networkd
  # which is simpler for static/DHCP-only setups.
  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Type = "ether";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
    };
  };

  # --- SSH: port 22 (Hetzner default, not 8422) ---
  services.openssh = {
    enable = true;
    ports = lib.mkForce [ 22 ];
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = lib.mkForce false;
    };
  };

  # Authorize all YubiKey SSH keys for root access. These match the keys
  # registered in the Hetzner Cloud project. Source of truth for the
  # public keys is user-config/modules/vcs/git/yubikey.nix.
  users.users.root.openssh.authorizedKeys.keys = [
    # GPG-based SSH key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILX+wxTLnIemOShAhsDgBpst0X/Ybu7SGZChaLSX/e7B"
    # YubiKey 28656036
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIey7k133RLvHWG7AybBxK8la06QCKw5OGoxvi0IWqUaAAAACHNzaDpBdXRo yubikey-28656036-auth"
    # YubiKey 28656210
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDjsRp17ZN3bBNsJzsS1UmXmztxnPChAIuM2sB8X47jvAAAACHNzaDpBdXRo yubikey-28656210-auth"
    # YubiKey 32149556
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIObcjrmJ0U0y2K4WSTNP3s4iO3G+Jz4YmfiUPac++lMeAAAACHNzaDpBdXRo yubikey-32149556-auth"
    # YubiKey 33200429
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKb8IpultzzxnlcmL+DxNXNxMFWUBwIuyIiSY0EVwiRlAAAACHNzaDpBdXRo yubikey-33200429-auth"
  ];

  # --- Hetzner Cloud guest agent ---
  services.qemuGuest.enable = true;

  # --- Serial console for Hetzner's web console ---
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200n8"
  ];
}
