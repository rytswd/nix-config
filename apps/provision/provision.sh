# shellcheck shell=bash
#
# `provision` -- first install of a NixOS host over SSH via nixos-anywhere.
# See ./default.nix for the wiring rationale and
# docs/runbooks/remote-provision.org for the full flow (who needs what,
# day-2 deploys, host-key trade-offs).
#
# FLAKE_REF and NIXOS_HOSTS are injected by default.nix: the flake's own
# source path and the nixosConfigurations attr names, respectively.

set -euo pipefail

flake_ref="${FLAKE_REF:?provision: FLAKE_REF not set (run via the flake app)}"

# NIXOS_HOSTS is derived from the flake's nixosConfigurations attr names at
# evaluation time, so a typo'd host fails fast with the real candidates
# instead of deep inside nixos-anywhere's own flake evaluation.
read -ra hosts <<<"${NIXOS_HOSTS:?provision: NIXOS_HOSTS not set (run via the flake app)}"

usage() {
    cat >&2 <<EOF
usage: nix run .#provision -- <host> <ssh-target> [options] [nixos-anywhere flags...]

  <host>        a nixosConfigurations attribute name (candidates below)
  <ssh-target>  root-capable SSH destination of the machine to install,
                e.g. root@203.0.113.7

options:
  --seed-host-key <path>  stage <path> as the target's
                          /etc/ssh/ssh_host_ed25519_key via --extra-files,
                          so a recreated instance keeps its enrolled sops
                          identity (see docs/runbooks/remote-provision.org)
  --dry-run               print the fully-resolved nixos-anywhere command
                          and exit without connecting anywhere

Any other flag is passed through to nixos-anywhere verbatim.
'--build-on local' is added unless you pass your own --build-on.

hosts:
$(printf '  %s\n' "${hosts[@]}")
EOF
}

###----------------------------------------
##  Argument parsing
#------------------------------------------
if [ $# -ge 1 ] && { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    usage
    exit 0
fi
if [ $# -lt 2 ]; then
    usage
    exit 2
fi

host="$1"
ssh_target="$2"
shift 2

dry_run=false
seed_key=""
passthrough=()
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        --seed-host-key)
            if [ $# -lt 2 ]; then
                printf 'provision: --seed-host-key requires a path\n' >&2
                exit 2
            fi
            seed_key="$2"
            shift 2
            ;;
        *)
            passthrough+=("$1")
            shift
            ;;
    esac
done

###----------------------------------------
##  Host resolution
#------------------------------------------
host_known=false
for h in "${hosts[@]}"; do
    if [ "$h" = "$host" ]; then
        host_known=true
        break
    fi
done
if ! $host_known; then
    printf 'provision: unknown host: %s\n' "$host" >&2
    printf 'provision: known nixosConfigurations:\n' >&2
    printf '  %s\n' "${hosts[@]}" >&2
    exit 1
fi

###----------------------------------------
##  Optional host-key seeding
#------------------------------------------
# A recreated cloud instance gets a brand-new SSH host key, which breaks its
# sops recipient identity (the age recipient is derived from the host key --
# see air/v0.1/secrets-host-enrolment.org and, once it lands,
# docs/runbooks/secrets-enrolment.org). Seeding the previous key via
# nixos-anywhere's --extra-files lets the new instance keep the enrolled
# identity, at the cost of private key material passing through the
# provisioner; the cleaner alternative is a fresh key plus re-enrolment.
#
# ed25519 is assumed: it is the NixOS default host key and the only type
# ssh-to-age can convert.
extra_files=""
if [ -n "$seed_key" ]; then
    if [ ! -r "$seed_key" ]; then
        printf 'provision: --seed-host-key: cannot read %s\n' "$seed_key" >&2
        exit 1
    fi
    # mktemp -d gives mode 700, so the staged private key is never readable
    # by other users; cleaned up on any exit. nixos-anywhere is run as a
    # child (not exec'd) so the EXIT trap still fires after the install.
    extra_files="$(mktemp -d)"
    trap 'rm -rf "$extra_files"' EXIT
    install -d -m 755 "$extra_files/etc/ssh"
    install -m 600 "$seed_key" "$extra_files/etc/ssh/ssh_host_ed25519_key"
    if [ -r "$seed_key.pub" ]; then
        install -m 644 "$seed_key.pub" "$extra_files/etc/ssh/ssh_host_ed25519_key.pub"
    else
        ssh-keygen -y -f "$seed_key" > "$extra_files/etc/ssh/ssh_host_ed25519_key.pub"
        chmod 644 "$extra_files/etc/ssh/ssh_host_ed25519_key.pub"
    fi
fi

###----------------------------------------
##  Nix config for nested invocations
#------------------------------------------
# The inner `nix run github:nix-community/nixos-anywhere` (and the builds it
# spawns) needs flakes enabled in its own right -- CLI flags don't propagate
# to child nix processes, NIX_CONFIG does. accept-flake-config picks up this
# flake's substituters non-interactively. Append any pre-set NIX_CONFIG so
# we don't clobber it.
NIX_CONFIG="experimental-features = nix-command flakes pipe-operators
accept-flake-config = true
${NIX_CONFIG:-}"
export NIX_CONFIG

###----------------------------------------
##  Resolve and run
#------------------------------------------
# --build-on local by default: targets may be smaller than the provisioner
# (or too small to build at all), and the provisioner is the machine with
# private-repo access and cache credentials. Overridable by passing your
# own --build-on in the passthrough flags.
cmd=(nix run github:nix-community/nixos-anywhere --
    --flake "$flake_ref#$host")

build_on_overridden=false
for a in "${passthrough[@]}"; do
    if [ "$a" = "--build-on" ]; then
        build_on_overridden=true
        break
    fi
done
if ! $build_on_overridden; then
    cmd+=(--build-on local)
fi

if [ -n "$extra_files" ]; then
    cmd+=(--extra-files "$extra_files")
fi

cmd+=("${passthrough[@]}" "$ssh_target")

# Always print the resolved command -- the app doubles as documentation of
# the underlying nixos-anywhere invocation, and thin wrappers earn trust by
# showing exactly what they run.
printf 'provision: host   = %s\n' "$host"
printf 'provision: target = %s\n' "$ssh_target"
printf 'provision: resolved command:\n    '
printf '%q ' "${cmd[@]}"
printf '\n'

if $dry_run; then
    printf 'provision: --dry-run, not executing\n'
    exit 0
fi

"${cmd[@]}"
