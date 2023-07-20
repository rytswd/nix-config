#!/usr/bin/env bash

NIXOS_IP=""
read -r -p "What is the IP for NixOS Virtual Machine?: " NIXOS_IP
if [[ $NIXOS_IP == "" ]]; then
    echo "ERROR: No IP provided for NixOS, exiting"
    exit 1
fi
NIXOS_PORT="22"
NIXOS_BLOCK_DEVICE="nvme0n1"

cat <<EOD

Summary of the configuration:

	NixOS IP:   $NIXOS_IP
	NixOS Port: $NIXOS_PORT

	NixOS Block Device: $NIXOS_BLOCK_DEVICE

EOD

ssh -o PubkeyAuthentication=no \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -p"${NIXOS_PORT}" \
    "root@${NIXOS_IP}" " \
		parted /dev/${NIXOS_BLOCK_DEVICE} -- mklabel gpt; \
		parted /dev/${NIXOS_BLOCK_DEVICE} -- mkpart primary 512MiB -8GiB; \
		parted /dev/${NIXOS_BLOCK_DEVICE} -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/${NIXOS_BLOCK_DEVICE} -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/${NIXOS_BLOCK_DEVICE} -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/${NIXOS_BLOCK_DEVICE}p1; \
		mkswap -L swap /dev/${NIXOS_BLOCK_DEVICE}p2; \
		mkfs.fat -F 32 -n boot /dev/${NIXOS_BLOCK_DEVICE}p3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
  			services.openssh.enable = true;\n \
			services.openssh.passwordAuthentication = true;\n \
			services.openssh.permitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
	"
