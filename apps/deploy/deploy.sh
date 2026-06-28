# shellcheck shell=bash
#
# `deploy` -- day-2 `nixos-rebuild switch` against a remote host.
# See ./default.nix for the wiring rationale and
# docs/runbooks/remote-provision.org for the full flow.
#
# FLAKE_REF and NIXOS_HOSTS are injected by default.nix: the flake's own
# source path and the nixosConfigurations attr names, respectively.

set -euo pipefail

flake_ref="${FLAKE_REF:?deploy: FLAKE_REF not set (run via the flake app)}"

# Same derived host list as the provision app: a typo'd host fails fast
# with the real candidates instead of mid-evaluation.
read -ra hosts <<<"${NIXOS_HOSTS:?deploy: NIXOS_HOSTS not set (run via the flake app)}"

usage() {
    cat >&2 <<EOF
usage: nix run .#deploy -- <host> <ssh-target> [options] [nixos-rebuild flags...]

  <host>        a nixosConfigurations attribute name (candidates below)
  <ssh-target>  sudo-capable SSH destination of the running host,
                e.g. ryota@203.0.113.7

options:
  --dry-run     print the fully-resolved nixos-rebuild command and exit
                without connecting anywhere

Any other flag is passed through to nixos-rebuild verbatim. The build runs
locally by default; pass --build-host <ssh-target> for the rare case the
target should build for itself.

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
passthrough=()
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
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
    printf 'deploy: unknown host: %s\n' "$host" >&2
    printf 'deploy: known nixosConfigurations:\n' >&2
    printf '  %s\n' "${hosts[@]}" >&2
    exit 1
fi

###----------------------------------------
##  Nix config for nested invocations
#------------------------------------------
# nixos-rebuild spawns its own child nix processes for evaluation and the
# build -- CLI flags don't propagate to them, NIX_CONFIG does.
# accept-flake-config picks up this flake's substituters non-interactively.
# Append any pre-set NIX_CONFIG so we don't clobber it.
NIX_CONFIG="experimental-features = nix-command flakes pipe-operators
accept-flake-config = true
${NIX_CONFIG:-}"
export NIX_CONFIG

###----------------------------------------
##  Resolve and run
#------------------------------------------
# No --build-host by default: nixos-rebuild then builds locally on the
# provisioner and copies the closure over, which is the point -- targets
# may be small, and only the provisioner has private-repo access.
# --use-remote-sudo because the day-2 target login is a regular user (root
# SSH is a first-install-only affordance).
cmd=(nixos-rebuild switch
    --flake "$flake_ref#$host"
    --target-host "$ssh_target"
    --use-remote-sudo)

cmd+=("${passthrough[@]}")

# Always print the resolved command -- the app doubles as documentation of
# the underlying nixos-rebuild invocation.
printf 'deploy: host   = %s\n' "$host"
printf 'deploy: target = %s\n' "$ssh_target"
printf 'deploy: resolved command:\n    '
printf '%q ' "${cmd[@]}"
printf '\n'

if $dry_run; then
    printf 'deploy: --dry-run, not executing\n'
    exit 0
fi

exec "${cmd[@]}"
