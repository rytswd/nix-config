#!/usr/bin/env bash
# shellcheck shell=bash

# setup-yubikey.sh
# Generates two resident SSH keys on a YubiKey:
#   1. Signing key (for git commit signing)
#   2. Auth key (for SSH authentication)
#
# Outputs public keys for yubikey.nix and private key stubs for SOPS.

set -euo pipefail

# --- Prerequisites Check ---
for cmd in ykman ssh-keygen; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is not installed."
        exit 1
    fi
done

# --- Detect YubiKey ---
echo "=== YubiKey SSH Key Setup ==="
echo "Please plug in your YubiKey and press Enter..."
read -r

SERIAL=$(ykman list --serials 2>/dev/null | head -n1)
if [[ -z "$SERIAL" ]]; then
    echo "Error: No YubiKey detected."
    exit 1
fi
echo "Detected YubiKey Serial: $SERIAL"
echo ""

# --- Temp directory for key generation ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# --- Function to generate and display a key ---
generate_key() {
    local purpose=$1      # "signing" or "auth"
    local application=$2  # e.g., "ssh:GitSigning" or "ssh:Auth"
    local key_path="${TMPDIR}/id_${purpose}"

    echo "================================================================"
    echo "Generating ${purpose^^} key (application=${application})"
    echo ">>> TOUCH YOUR YUBIKEY when it blinks <<<"
    echo "================================================================"

    ssh-keygen -t ed25519-sk \
        -O resident \
        -O "application=${application}" \
        -C "yubikey-${SERIAL}-${purpose}" \
        -N "" \
        -f "$key_path"

    echo ""
    echo "--- PUBLIC KEY (for yubikey.nix) ---"
    cat "${key_path}.pub"
    echo ""

    echo "--- PRIVATE KEY STUB (for SOPS repository) ---"
    cat "$key_path"
    echo ""

    echo ">>> Copy the above keys, then press Enter to continue..."
    read -r
}

# --- Generate both keys ---
generate_key "auth" "ssh:Auth"
generate_key "signing" "ssh:GitSigning"

echo "================================================================"
echo "Setup Complete!"
echo ""
echo "Next steps:"
echo "  1. Add public keys to yubikey.nix"
echo "  2. Add private key stubs to your SOPS repository"
echo "  3. Run 'nixos-rebuild switch' or 'home-manager switch'"
echo "================================================================"
