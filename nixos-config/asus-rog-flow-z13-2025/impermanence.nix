{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./disko.nix
    # Ensure you have inputs.impermanence.nixosModules.impermanence imported in your flake
  ];

  # 1. Bootloader must support LUKS
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 2. Filesystems binding (Disko does this, but we ensure /nix/persist is needed for boot)
  fileSystems."/nix/persist".neededForBoot = true;

  # 3. THE ROLLING ROOT LOGIC
  # This runs in the Init RAM Disk, before the root FS is mounted.
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS root to blank snapshot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-zroot.service" ];
    before = [ "sysroot.mount" ];
    path = with pkgs; [ zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      # 1. Import the pool (read-only likely, so we might need to be careful)
      # In systemd initrd, zfs-import handles the import.

      # 2. Roll the old root (Keep 10 generations, for example)
      # We rename the current 'root' to 'root-timestamp'

      dataset="zroot/store/root"
      timestamp=$(date +%Y%m%d%H%M%S)

      # Move the current state to a backup
      # Note: We rollback to @blank immediately after, creating a fresh slate.
      # If you strictly want 'rolling' backups accessible:
      zfs rename "$dataset" "$dataset-old-$timestamp"

      # clone the blank snapshot to create the new active root
      zfs send "zroot/store/root@blank" | zfs receive "$dataset"

      # Optional: Clean up very old datasets here if desired
    '';
  };

  # 4. IMPERMANENCE (Integrated Preservation)
  # Everything in / is wiped on boot. We strictly define what survives.
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/containers"
      "/var/lib/fwupd"
      "/var/lib/iwd"
      "/var/lib/syncthing"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.admin = {
      directories = [
        ".ssh"
      ];
    };
    users.ryota = {
      directories = [
        "Coding"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        ".emacs.d"
        ".ssh"
        ".gnupg"
      ];
      files = [
        # To be updated
      ];
    };
  };

  # 5. OPTIONAL: Remote Unlock (Initrd SSH)
  # Since you are using LUKS, you might want to unlock via SSH.
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    # NOTE: You must generate this manually once.
    #     ssh-keygen -t ed25519 -N "" -f /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key
    hostKeys = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFr6E1ZFjz1r7gHF9OfWkVPJmWNuwWVqbpakvG/C3Ck1 openpgp:0x12A83CB5" ];
  };
}
