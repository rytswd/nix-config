{ pkgs
, lib
, config
, inputs
, ...}:

# AWS EC2 *.metal instance overrides. Analogue of hetzner-cloud.nix for
# bare-metal EC2 boxes used as interactive Nix dev / build hosts.
#
# Why bare metal: NixOS VM tests need RDWR `/dev/kvm` (TCG emulation has
# different timing and produces false results), and FUSE passthrough needs
# a real kernel. A `.metal` instance gives both; virtualised EC2 and most
# container runtimes give neither.
#
# This module is disk-layout agnostic. A host using the stock NixOS AMI
# imports `${modulesPath}/virtualisation/amazon-image.nix` itself; a host
# that owns its layout via disko does NOT, and instead sets
# `boot.loader.grub` + initrd modules directly.

let
  allKeys = import "${inputs.self}/shared/keys.nix";
in
{
  # --- Boot / initrd ---
  # ENA (network) + NVMe (every EBS / instance-store device on Nitro) must
  # be in the initrd or the root pool can't be found.
  boot.initrd.availableKernelModules = [ "nvme" "ena" ];
  boot.kernelParams = [
    # EC2 serial console (`aws ec2 get-console-output`).
    "console=tty1"
    "console=ttyS0,115200n8"
    # Never escalate a transient EBS hiccup to an I/O error (AWS guidance).
    "nvme_core.io_timeout=4294967295"
  ];

  # --- Networking: systemd-networkd, not NetworkManager ---
  # Headless server; single ENA NIC on DHCP.
  networking.networkmanager.enable = lib.mkDefault false;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."10-ena" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };

  # --- SSH ---
  # Port 22 (EC2 SG convention), key-only. core/ssh.nix defaults to 8422
  # with passwords on -- override both.
  services.openssh = {
    enable = true;
    ports = lib.mkForce [ 22 ];
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = lib.mkForce false;
      # NLB / NAT idle timeouts silently drop quiet connections during long
      # single-crate compiles; keepalive turns that into a clean failure.
      ClientAliveInterval = 60;
    };
  };
  # Authorize all YubiKey SSH keys for root. Same source of truth as
  # hetzner-cloud.nix. The host config additionally creates the `ryota`
  # normal user; root + sudo is the recovery path.
  users.users.root.openssh.authorizedKeys.keys =
    [ allKeys.gpg-ssh ] ++
    (lib.mapAttrsToList (_: k: k.auth) allKeys.yubikey);

  # --- Reachability when SSH is unconfigured / broken ---
  # SSM session manager works as soon as the instance has an IAM profile
  # with `AmazonSSMManagedInstanceCore`; no SG ingress needed.
  services.amazon-ssm-agent.enable = true;
  # mosh-style resumable sessions over flaky links.
  services.eternal-terminal.enable = true;

  # --- Nix builder tunables (from ec2-builder.nix) ---
  nix.settings = {
    system-features = [
      "kvm"
      "nixos-test"
      "big-parallel"
      "benchmark"
    ];
    max-jobs = lib.mkDefault "auto";
    build-dir = "/nix/var/nix/builds";
  };
  # tmpfs build dir: build artefacts never touch EBS, and a crashed build
  # can't leave a half-written store path on the durable pool.
  fileSystems."/nix/var/nix/builds" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=33%" "mode=700" "huge=within_size" ];
  };

  # --- Dev quality-of-life ---
  # Run unpatched dynamic binaries (e.g. rustup-installed toolchains).
  programs.nix-ld.enable = true;
  virtualisation.podman.enable = true;
  environment.systemPackages = with pkgs; [ awscli2 git ];

  time.timeZone = lib.mkDefault "Etc/UTC";
}
