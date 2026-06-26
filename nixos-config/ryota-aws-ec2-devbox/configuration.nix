{ config
, pkgs
, lib
, self
, inputs
, ...
}:

# AWS EC2 bare-metal dev box (Intel, r8idn.metal-96xl). Gives working
# /dev/kvm + FUSE passthrough for NixOS VM tests and FUSE-backed store
# work that can't run inside virtualised / containerised dev environments.
#
# Disk layout: ZFS striped across 6x io2 EBS (durable tier) with the
# instance-store NVMe attached as L2ARC at boot. Nix builds land on a
# RAM-backed tmpfs so the durable pool only sees finished store paths.

let
  allKeys = import "${self}/shared/keys.nix";
in
{
  imports = [
    "${self}/nixos-config/modules/core"
    # No modules/vpn here — this host is reached over its public address
    # (and SSM as fallback), not via the personal tailnet.
    "${self}/nixos-config/modules/filesystem/zfs.nix"

    # EC2 .metal overrides (ssm-agent, eternal-terminal, tmpfs build dir,
    # system-features = kvm/nixos-test/..., serial console, ENA/NVMe initrd).
    "${self}/nixos-config/modules/machine-specific/aws-ec2-metal.nix"

    # Create the `ryota` normal user (wheel group etc.).
    "${self}/user-config/ryota/create.nix"
  ];

  ###----------------------------------------
  ##   Identity
  #------------------------------------------
  networking.hostName = "ryota-aws-ec2-devbox";
  # Required for ZFS; arbitrary but stable. `head -c4 /dev/urandom | xxd -p`.
  networking.hostId = "e2a917c4";

  ###----------------------------------------
  ##   Boot / kernel (Intel .metal + ZFS)
  #------------------------------------------
  boot = {
    kernelModules = [ "kvm-intel" ];
    # ZFS lags mainline; pin a kernel the chosen zfs package supports.
    # nix-base.nix may set a different default -- the explicit assignment
    # here wins.
    kernelPackages = pkgs.linuxPackages_6_18;
    zfs = {
      package = pkgs.zfs_2_4;
      # zroot IS the root fs; if it doesn't import the box doesn't boot, and
      # this is a scratch builder. Set explicitly to silence the 26.11
      # default-change warning.
      forceImportRoot = true;
      # Import via partlabels so `zpool status` shows disko's disk-ebsN-zfs
      # names instead of whichever of the ~4 by-id aliases udev's readdir
      # order happens to serve first.
      devNodes = "/dev/disk/by-partlabel";
    };
    kernelParams = [
      # ARC 1TiB: leave headroom for the 1TiB builds tmpfs + 256G /tmp +
      # build processes on a ~3TiB box. Scale down if you launch a smaller
      # instance type.
      "zfs.zfs_arc_max=1099511627776"
      # Absorb substitution bursts into txgs (default caps at 4GiB).
      "zfs.zfs_dirty_data_max=34359738368"
      # L2ARC feed defaults are sized for 2010-era SSDs. Feed at NVMe pace
      # and cache sequential NAR reads too.
      "zfs.l2arc_write_max=1073741824"
      "zfs.l2arc_write_boost=2147483648"
      "zfs.l2arc_noprefetch=0"
      # zstd compresses 128K records to ~68K; the default 128K SSD
      # aggregation limit then forbids merging, so each EBS volume stalls
      # on queue depth. 1M aggregation yields ~240KiB device I/Os and gets
      # close to the provisioned io2 IOPS×size envelope.
      "zfs.zfs_vdev_aggregation_limit_non_rotating=1048576"
      # rustc/LLVM are heap-hungry; THP=always typically buys a few percent.
      "transparent_hugepage=always"
      # Snappier interactive sessions while hundreds of cores compile.
      "preempt=full"
      # 0 scans the full ARC lists so buffers evicted during build churn
      # still reach the (pool-sized) persistent cache.
      "zfs.l2arc_headroom=0"
      # Wiped instance-store devices get a full TRIM when re-added after
      # stop/start, keeping the FTL clean for the 1-2GiB/s refill.
      "zfs.l2arc_trim_ahead=100"
      "zfs.zfs_vdev_read_gap_limit=131072"
      "zfs.zfs_vdev_async_read_max_active=8"
      "zfs.zfs_vdev_async_read_min_active=2"
    ];
    loader.grub = {
      enable = true;
      # `devices` is set automatically by disko from the EF02 partition.
      # Mirror the kernel's serial console so grub itself is visible in
      # `aws ec2 get-console-output`.
      extraConfig = ''
        serial --unit=0 --speed=115200
        terminal_input console serial
        terminal_output console serial
      '';
    };
    # core/tmp.nix already enables tmpfs /tmp; cap it so /tmp + the builds
    # tmpfs + ARC can't sum past physical RAM (no swap here).
    tmp.tmpfsSize = "256G";
  };

  ###----------------------------------------
  ##   Nix daemon tunables (large host)
  #------------------------------------------
  nix.settings = {
    # nix-base.nix turns this on; on the hot path it slows builds. Batch it
    # via the optimise timer instead.
    auto-optimise-store = lib.mkForce false;
    max-jobs = lib.mkForce 32;
    # Mass substitution: defaults leave most of the pipe idle when pulling
    # 100k+ store paths.
    max-substitution-jobs = 128;
    http-connections = lib.mkForce 128;
    # Don't ignore a substituter for an hour after a miss; hydra often
    # uploads moments after the first ask.
    narinfo-cache-negative-ttl = 60;
  };
  nix.optimise = {
    automatic = true;
    dates = [ "*-*-* 00/3:00:00" ];
  };

  ###----------------------------------------
  ##   ZFS / EBS housekeeping
  #------------------------------------------
  # EBS has no discard support, so the weekly zpool trim would only fail
  # noisily; L2ARC devices are not covered by the trim timer anyway.
  services.zfs.trim.enable = lib.mkForce false;
  # auto-snapshot from filesystem/zfs.nix is pointless on a scratch builder.
  services.zfs.autoSnapshot.enable = lib.mkForce false;

  services.irqbalance.enable = true;
  services.udev.extraRules = ''
    # ZFS schedules its own I/O; kernel writeback throttling underneath it
    # only fights the vdev scheduler. Covers pool and L2ARC devices.
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*", ATTR{queue/wbt_lat_usec}="0"
  '';

  ###----------------------------------------
  ##   Instance-store NVMe → L2ARC re-attach
  #------------------------------------------
  # Instance-store NVMe is wiped on stop/start and comes back blank under
  # new serials. A missing cache vdev never blocks pool import; this unit
  # re-attaches whatever came back. Idempotent; matches by NVMe model
  # string, never by-id (serials change every stop/start).
  systemd.services.zpool-l2arc-ensure = {
    description = "Attach instance-store NVMe as zroot L2ARC";
    # zroot is the root pool, imported in the initrd -- there is no stage-2
    # zfs-import-zroot.service to order against. zfs-import.target always
    # exists and is reached once imports are done.
    after = [ "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      config.boot.zfs.package
      config.systemd.package
      pkgs.gawk
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      pool=zroot

      # Drop cache vdevs whose backing device vanished on stop/start.
      zpool status "$pool" | awk '
        $1 == "cache" { in_cache = 1; next }
        in_cache && NF == 0 { in_cache = 0 }
        in_cache && ($2 == "UNAVAIL" || $2 == "FAULTED" || $2 == "REMOVED") { print $1 }
      ' | while read -r vdev; do
        zpool remove "$pool" "$vdev" || true
      done

      # Current member paths, resolved to kernel devices: after a reboot the
      # pool reports cache vdevs under /dev/disk/by-id, not the path they
      # were originally added by.
      members=$(zpool status -P "$pool" | awk '$1 ~ "^/dev/" { print $1 }' \
        | while read -r p; do readlink -f "$p" 2>/dev/null || true; done)

      # Attach instance-store devices that are not already pool members.
      for dev in /dev/nvme*n1; do
        [ -b "$dev" ] || continue
        model=$(cat "/sys/block/''${dev##*/}/device/model" 2>/dev/null) || continue
        case "$model" in
          *"Instance Storage"*) ;;
          *) continue ;;
        esac
        real=$(readlink -f "$dev")
        if printf '%s\n' "$members" | grep -q "^$real"; then
          continue
        fi
        # -f: a wiped-looking device may carry a stale l2arc label from a
        # previous incarnation of this pool. The model filter above
        # guarantees only instance store is ever added, and only as cache.
        zpool add -f "$pool" cache "$dev" || true
      done

      # Refresh udev's filesystem-probe cache so lsblk's FSTYPE isn't blank
      # on freshly-added cache devices.
      udevadm trigger --settle /dev/nvme*n1p1 2>/dev/null || true
    '';
  };

  systemd.tmpfiles.rules = [
    # No cmdline param exists for THP defrag; 'defer' avoids
    # direct-compaction stalls in wide malloc-heavy compiles.
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer"
  ];

  ###----------------------------------------
  ##   Users
  #------------------------------------------
  # `ryota` comes from user-config/ryota/create.nix (wheel + initial pw).
  # Add the kvm group and authorize the same YubiKey set as root so direct
  # `ssh ryota@…` works without going via root + sudo.
  users.users.ryota = {
    extraGroups = [ "kvm" ];
    openssh.authorizedKeys.keys =
      [ allKeys.gpg-ssh allKeys.secretive allKeys.provisioner ] ++
      (lib.mapAttrsToList (_: k: k.auth) allKeys.yubikey);
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = [ config.boot.zfs.package ];

  system.stateVersion = "25.11";
}
