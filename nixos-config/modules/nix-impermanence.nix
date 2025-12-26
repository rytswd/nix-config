{
  pkgs,
  lib,
  config,
  ...
}:

{
  config =  {
    # Only added to force build failure when missing.
    boot.loader.systemd-boot.enable = true;

    fileSystems."/nix/persist".neededForBoot = true;
    programs.fuse.userAllowOther = true;

    # Make fusermount available for home-manager activation
    environment.systemPackages = [ pkgs.fuse ];

    # TODO: Review this to make it work, currently failing to start up.
    # boot.initrd.systemd = {
    #   enable = true;
    #   rollback = {
    #     description = "Rollback ZFS root to blank snapshot";
    #     wantedBy = [ "initrd.target" ];
    #     after = [ "zfs-import-zroot.service" ];
    #     before = [ "sysroot.mount" ];
    #     path = with pkgs; [ zfs ];
    #     unitConfig.DefaultDependencies = "no";
    #     serviceConfig.Type = "oneshot";
    #     script = ''
    #       # 1. Import the pool (read-only likely, so we might need to be careful)
    #       # In systemd initrd, zfs-import handles the import.

    #       # 2. Roll the old root (Keep 10 generations, for example)
    #       # We rename the current 'root' to 'root-timestamp'

    #       dataset="zroot/store/root"
    #       timestamp=$(date +%Y%m%d%H%M%S)

    #       # Move the current state to a backup
    #       # Note: We rollback to @blank immediately after, creating a fresh slate.
    #       # If you strictly want 'rolling' backups accessible:
    #       zfs rename "$dataset" "$dataset-old-$timestamp"

    #       # clone the blank snapshot to create the new active root
    #       zfs send "zroot/store/root@blank" | zfs receive "$dataset"

    #       # Optional: Clean up very old datasets here if desired
    #     '';
    #   };
    # };

    # Everything in / is wiped on boot. I need to define what survives here.
    # For user home directory, they are configured separately per user.
    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/bluetooth"
        "/var/lib/containers"
        "/var/lib/docker"
        "/var/lib/fwupd"
        "/var/lib/libvirt"
        "/var/lib/pcsc"
        "/var/lib/qemu"
        "/var/lib/sddm"
        "/var/lib/systemd/coredump"
        "/var/lib/tailscale"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
