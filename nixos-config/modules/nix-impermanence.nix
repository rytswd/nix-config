{
  pkgs,
  lib,
  config,
  ...
}:

let
  # ----------------------------------------------------------------------
  # Master switch for *true* ephemeral root.
  #
  # When enabled, the initrd rolls `zroot/store/root` back to its pristine
  # `@blank` snapshot on every boot, so `/` is wiped and only paths listed
  # in `environment.persistence` below survive. The previous attempt did a
  # fragile `zfs rename` + `send | receive`; a plain `zfs rollback -r` is
  # the robust, idempotent pattern.
  #
  # KEEP THIS `false` until the migration checklist is done -- enabling it
  # blind WILL destroy live state on the next reboot.
  #
  # Audit (2026-06-22) found live, NON-persisted state on the root dataset
  # that a rollback will erase unless first added to the persistence list
  # AND its current contents copied into /nix/persist:
  #   - /var/lib/flatpak                      installed Flatpak apps
  #   - /var/lib/AccountsService              per-user DM settings / avatars
  #   - /var/lib/boltd                        Thunderbolt authorisations
  #   - /var/lib/colord                       colour profiles
  #   - /etc/wpa_supplicant/imperative.conf   imperatively-added WiFi
  #   - /etc/asusd/*.ron                      ASUS fan curves + Aura RGB
  #         (persist ONLY if not managed declaratively by the asusd module)
  #
  # Migration per path, before flipping the switch:
  #   mkdir -p /nix/persist/<path>
  #   rsync -aHAX --remove-source-files /<path>/ /nix/persist/<path>/
  #   then add <path> to environment.persistence."/nix/persist".directories
  #
  # NOTE: this changes the initrd, which is exactly what SecureBoot signs.
  # Fix SecureBoot first, then enable this and re-sign / re-enroll.
  # ----------------------------------------------------------------------
  enableEphemeralRoot = false;
in
{
  config = lib.mkMerge [
   {
    # Only added to force build failure when missing.
    # boot.loader.systemd-boot.enable = true;

    fileSystems."/nix/persist".neededForBoot = true;
    programs.fuse.userAllowOther = true;

    # Make fusermount available for home-manager activation
    environment.systemPackages = [ pkgs.fuse ];

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
        "/var/lib/sbctl"
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
   }

    # Roll `/` back to a pristine @blank in the initrd. Gated -- see the
    # `enableEphemeralRoot` checklist at the top of this file.
    (lib.mkIf enableEphemeralRoot {
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.services.rollback = {
        description = "Rollback zroot/store/root to a pristine @blank snapshot";
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-zroot.service" ];
        before = [ "sysroot.mount" ];
        path = [ pkgs.zfs ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = "zfs rollback -r zroot/store/root@blank";
      };
    })
  ];
}
