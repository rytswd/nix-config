# shellcheck shell=bash
#
# `install` -- guided, phase-by-phase bare-metal NixOS installer for hosts
# in this flake's `nixosConfigurations`. See ./default.nix for the wiring;
# the authoritative *why* is docs/runbooks/bare-metal-install.org -- this
# script is the *how*.
#
# Runnable from the custom installer ISO (nixos-config/iso/) or a stock
# NixOS installer ISO:
#
#     nix run github:rytswd/nix-config#install -- [--dry-run] [<host>]
#
# Every phase prints its underlying command before running it and asks for
# explicit confirmation, so the script doubles as living documentation and
# any phase can be taken over manually when something needs intervention.
#
# FLAKE_REF is injected by default.nix (the flake's own source path), so
# host resolution and the preflight library come from the same revision
# this app was evaluated from.

set -euo pipefail

flake_ref="${FLAKE_REF:?install: FLAKE_REF not set (run via the flake app)}"

###----------------------------------------
##  Nix config for nested invocations
#------------------------------------------
# A stock installer ISO has no experimental features enabled, and CLI flags
# do not propagate to the child `nix` processes that disko and
# `nixos-install` spawn. NIX_CONFIG is read by every nix process in this
# environment, so set it once here -- same pattern as
# apps/bootstrap/bootstrap.sh. Append any pre-set NIX_CONFIG so we don't
# clobber it.
#
# Unlike bootstrap, no gh-token lookup: an installer environment has no
# authenticated `gh`, and a token never affects the preflight verdict
# anyway (the private input is git+ssh).
NIX_CONFIG="experimental-features = nix-command flakes pipe-operators
accept-flake-config = true
${NIX_CONFIG:-}"
export NIX_CONFIG

###----------------------------------------
##  Arguments
#------------------------------------------
usage() {
    cat <<'EOF'
usage: nix run github:rytswd/nix-config#install -- [--dry-run] [<host>]

Guided, phase-by-phase NixOS install for hosts in this flake's
nixosConfigurations: network check -> credential preflight -> repo clone
-> disko -> nixos-install -> post-install checklist. Each phase prints its
underlying command before running and asks for explicit confirmation.

  <host>      a nixosConfigurations attribute name (omit to get the list)
  --dry-run   walk every phase printing the commands; only the read-only
              probes (network check, credential preflight) actually run
EOF
}

dry_run=0
host=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
        -h|--help) usage; exit 0 ;;
        -*)
            printf 'install: unknown flag: %s\n' "$arg" >&2
            usage >&2
            exit 2
            ;;
        *)
            if [ -n "$host" ]; then
                printf 'install: at most one host, got "%s" and "%s"\n' "$host" "$arg" >&2
                exit 2
            fi
            host="$arg"
            ;;
    esac
done

###----------------------------------------
##  Helpers
#------------------------------------------
abort() {
    printf 'install: %s\n' "$1" >&2
    exit 1
}

# Phase banner -- same boxed shape as the section headers in this repo's
# nix/shell sources, so the on-screen structure matches the code's.
phase() {
    printf '\n###========================================\n'
    printf '##   %s\n' "$1"
    printf '#==========================================\n'
}

# Print the exact command a phase is about to run (or would run, under
# --dry-run), so a failed phase can be re-run by hand verbatim.
show_cmd() {
    printf '\n    $ %s\n\n' "$*"
}

# Read-only probes run even under --dry-run -- a dry run should still tell
# the truth about *this* machine's network and credentials.
run_cmd_ro() {
    show_cmd "$@"
    "$@"
}

confirm() {
    if [ "$dry_run" = 1 ]; then
        printf 'install: [dry-run] %s -- continuing\n' "$1"
        return 0
    fi
    local reply
    read -r -p "install: $1 [y/N] " reply
    case "$reply" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

# Inter-phase gate: declining is a clean stop, not an error -- completed
# phases are safe to repeat on the next run (clone is reused, disko can
# re-mount, preflight is read-only).
proceed() {
    if confirm "$1"; then
        return 0
    fi
    printf 'install: stopped. Completed phases are safe to repeat -- re-run when ready.\n'
    exit 0
}

# Mutating commands: printed always, confirmed and executed only outside
# --dry-run.
run_confirmed() {
    local prompt="$1"
    shift
    show_cmd "$@"
    if [ "$dry_run" = 1 ]; then
        printf 'install: [dry-run] not executed\n'
        return 0
    fi
    if ! confirm "$prompt"; then
        printf 'install: stopped. Completed phases are safe to repeat -- re-run when ready.\n'
        exit 0
    fi
    "$@"
}

# disko and nixos-install need root; the stock ISO defaults to the `nixos`
# user. Resolved once so every printed command shows exactly what will run.
sudo_prefix=()
if [ "$(id -u)" -ne 0 ]; then
    sudo_prefix=(sudo)
fi

###----------------------------------------
##  Host resolution
#------------------------------------------
# Hosts come from `nixosConfigurations` attribute names, so there is no
# separate registry to drift (the remote-provisioning apps take the same
# approach). attrNames never forces the configurations themselves, so this
# needs neither network nor the private input. `installer-iso` is excluded:
# it *is* the installer image, not an install target.
mapfile -t hosts < <(
    nix eval --raw "$flake_ref#nixosConfigurations" \
        --apply 'cs: builtins.concatStringsSep "\n" (builtins.attrNames cs)' \
        | grep -v '^installer-iso$'
)
[ "${#hosts[@]}" -gt 0 ] || abort "could not list nixosConfigurations from $flake_ref"

if [ -z "$host" ]; then
    printf 'install: available hosts:\n'
    i=1
    for h in "${hosts[@]}"; do
        printf '  %2d) %s\n' "$i" "$h"
        i=$((i + 1))
    done
    if [ "$dry_run" = 1 ]; then
        printf 'install: [dry-run] no host given -- pass one to walk the remaining phases\n'
        exit 0
    fi
    read -r -p "install: select a host [1-${#hosts[@]}]: " sel
    case "$sel" in
        ''|*[!0-9]*) abort "host selection must be a number" ;;
    esac
    { [ "$sel" -ge 1 ] && [ "$sel" -le "${#hosts[@]}" ]; } || abort "host selection out of range"
    host="${hosts[$((sel - 1))]}"
fi

found=0
for h in "${hosts[@]}"; do
    if [ "$h" = "$host" ]; then
        found=1
    fi
done
if [ "$found" -ne 1 ]; then
    printf 'install: unknown host: %s\n' "$host" >&2
    printf 'install: available: %s\n' "${hosts[*]}" >&2
    exit 1
fi

printf 'install: target host = %s\n' "$host"
if [ "$dry_run" = 1 ]; then
    printf 'install: DRY RUN -- commands are printed, nothing destructive executes\n'
fi

###----------------------------------------
##  Phase 1: network check
#------------------------------------------
phase "Phase 1/6: network check"

# GitHub serves both the clone and most flake inputs, so one probe covers
# DNS + outbound TLS for everything that follows. Read-only: runs even
# under --dry-run.
if run_cmd_ro curl -fsS --max-time 10 -o /dev/null https://github.com; then
    printf 'install: network OK\n'
elif [ "$dry_run" = 1 ]; then
    printf 'install: [dry-run] network unreachable -- continuing anyway (a real run stops here; bring it up with e.g. nmtui)\n'
else
    abort "network unreachable -- bring it up first (e.g. nmtui for Wi-Fi), then re-run"
fi

proceed "Continue to credential preflight?"

###----------------------------------------
##  Phase 2: credential preflight
#------------------------------------------
phase "Phase 2/6: credential preflight"

# Shared with bootstrap (air/v0.1/private-input-stub.org). The verdict is
# the full-vs-degraded fork for everything downstream: full fetches the
# git+ssh private input as-is; degraded substitutes the public stub and
# the built system announces what is missing via eval warnings. Read-only:
# runs even under --dry-run. The :-degraded fallback is belt-and-braces --
# if the library somehow failed to set a verdict, degrading is the safe
# direction (it never blocks, only stubs).
# shellcheck source=/dev/null
. "$flake_ref/apps/lib/preflight.sh"
preflight_report
verdict="${PREFLIGHT_VERDICT:-degraded}"

proceed "Continue to repository setup (verdict: $verdict)?"

###----------------------------------------
##  Phase 3: repository
#------------------------------------------
phase "Phase 3/6: repository"

# /tmp by convention (machine READMEs): this clone only serves the
# install; the durable clone happens post-install via home-git-clone. An
# existing checkout -- a re-run after manual intervention, or running from
# a working tree -- is reused rather than re-cloned.
repo=""
d="$PWD"
while [ "$d" != / ]; do
    if [ -f "$d/flake.nix" ] && [ -d "$d/apps/install" ]; then
        repo="$d"
        break
    fi
    d="$(dirname "$d")"
done

if [ -n "$repo" ]; then
    printf 'install: already inside a checkout: %s -- skipping clone\n' "$repo"
elif [ -e /tmp/nix-config/flake.nix ]; then
    repo=/tmp/nix-config
    printf 'install: reusing existing clone at %s\n' "$repo"
else
    repo=/tmp/nix-config
    # HTTPS needs no credential for the public repo, so it is what the
    # degraded path must use; with a working SSH credential the git+ssh
    # form keeps later private-repo work on the same transport. Override
    # with NIXCFG_REPO_URL if the repo moves.
    if [ "$verdict" = full ]; then
        repo_url="${NIXCFG_REPO_URL:-git@github.com:rytswd/nix-config.git}"
    else
        repo_url="${NIXCFG_REPO_URL:-https://github.com/rytswd/nix-config}"
    fi
    run_confirmed "Clone to $repo?" git clone "$repo_url" "$repo"
fi

# The stub override can only be formed once the checkout location is known
# -- it is the same override the preflight printed, in absolute form,
# pointing at the stub *inside* the clone.
override_args=()
if [ "$verdict" != full ]; then
    override_args=(--override-input nix-config-private "path:$repo/stubs/nix-config-private")
    printf 'install: degraded eval -- the public stub will substitute for nix-config-private\n'
fi

proceed "Continue to disk partitioning (disko)?"

###----------------------------------------
##  Phase 4: disk partitioning (disko)
#------------------------------------------
phase "Phase 4/6: disk partitioning (disko)"

# Host -> config directory. Explicit only where the directory differs from
# the host name (same philosophy as apps/hm/dispatcher.sh: obvious from
# `git blame`, no clever introspection).
host_dir() {
    case "$1" in
        hetzner-k8s-cp-*) printf 'nixos-config/hetzner-k8s\n' ;;
        nixos-utm)        printf 'nixos-config/mbp-utm\n' ;;
        *)                printf 'nixos-config/%s\n' "$1" ;;
    esac
}

disko_dir="$repo/$(host_dir "$host")"
disko_files=()
for f in "$disko_dir"/disko*.nix; do
    [ -e "$f" ] || continue
    disko_files+=("$f")
done

disko_cmd=(nix run github:nix-community/disko/latest --)

if [ "${#disko_files[@]}" -eq 0 ]; then
    if [ "$dry_run" = 1 ] && [ ! -d "$disko_dir" ]; then
        printf 'install: [dry-run] no checkout at %s -- disko variants would be discovered as %s/disko*.nix\n' \
            "$repo" "$(host_dir "$host")"
    else
        printf 'install: no disko file under %s\n' "$disko_dir"
        printf 'install: partition and mount the target at /mnt manually, then continue\n'
    fi
elif [ "$dry_run" = 1 ]; then
    printf 'install: [dry-run] %d disko variant(s) for %s; the file AND the mode are explicit choices -- a destructive mode is never the default:\n' \
        "${#disko_files[@]}" "$host"
    for f in "${disko_files[@]}"; do
        show_cmd "${sudo_prefix[@]}" "${disko_cmd[@]}" --mode '<format,mount|destroy,format,mount|mount>' "$f"
        case "$f" in
            *dual-boot*)
                printf 'install: [dry-run]   %s: destroy is refused for this layout -- it would take the foreign OS partitions with it (see the machine README)\n' \
                    "$(basename "$f")"
                ;;
        esac
    done
else
    printf 'install: disko layout variants for %s:\n' "$host"
    i=1
    for f in "${disko_files[@]}"; do
        printf '  %d) %s\n' "$i" "${f#"$repo"/}"
        i=$((i + 1))
    done
    if [ "${#disko_files[@]}" -eq 1 ]; then
        # A single variant still goes through the mode menu and the final
        # confirmation -- only the *file* is implied, never the decision.
        disko_file="${disko_files[0]}"
    else
        read -r -p "install: select a layout [1-${#disko_files[@]}] (no default): " sel
        case "$sel" in
            ''|*[!0-9]*) abort "layout selection must be a number; not defaulting" ;;
        esac
        { [ "$sel" -ge 1 ] && [ "$sel" -le "${#disko_files[@]}" ]; } || abort "layout selection out of range"
        disko_file="${disko_files[$((sel - 1))]}"
    fi

    printf 'install: disko modes (no default -- the destructive one must be an explicit choice):\n'
    printf '  1) format,mount          -- format only the partitions the file manages (keeps the partition table; the dual-boot-safe mode)\n'
    printf '  2) destroy,format,mount  -- WIPE the managed disk(s) and start from scratch\n'
    printf '  3) mount                 -- mount an already-formatted layout (resume after a reboot)\n'
    read -r -p "install: select a mode [1-3] (no default): " sel
    case "$sel" in
        1) mode="format,mount" ;;
        2) mode="destroy,format,mount" ;;
        3) mode="mount" ;;
        *) abort "mode selection must be 1-3; not defaulting" ;;
    esac

    case "$disko_file" in
        *dual-boot*)
            if [ "$mode" = "destroy,format,mount" ]; then
                abort "refusing destroy on a dual-boot layout -- it would take the foreign OS partitions with it; see the machine README for the manual prep instead"
            fi
            ;;
    esac

    run_confirmed "Run disko in mode '$mode'? This modifies disks" \
        "${sudo_prefix[@]}" "${disko_cmd[@]}" --mode "$mode" "$disko_file"
    printf 'install: verify the result before continuing:  mount | grep /mnt; lsblk\n'
fi

proceed "Continue to nixos-install?"

###----------------------------------------
##  Phase 5: nixos-install
#------------------------------------------
phase "Phase 5/6: nixos-install"

# `nixos-install` forwards `--override-input` to its underlying build, so
# the degraded path stays a single command instead of a separate closure
# build plus `--system`.
install_cmd=("${sudo_prefix[@]}" nixos-install --flake "$repo#$host")
if [ "${#override_args[@]}" -gt 0 ]; then
    install_cmd+=("${override_args[@]}")
fi
run_confirmed "Run nixos-install now?" "${install_cmd[@]}"

###----------------------------------------
##  Phase 6: post-install checklist
#------------------------------------------
phase "Phase 6/6: post-install checklist"

# Printed, never executed: each item either needs human judgement (which
# machine, which credential) or must run inside the new system.
repo_base="$(basename "$repo")"
cat <<EOF

install: NOTHING below is executed -- work through it in order (the
install: reasoning lives in docs/runbooks/bare-metal-install.org):

  [ ] Host key handover for sops: the new system's host key must be able
      to decrypt secrets before the first boot completes cleanly.
      Mechanism: air/v0.1/secrets-host-enrolment.org; credential side:
      docs/runbooks/credential-bootstrap.org; details in the private repo.

  [ ] Verify the bootloader entry exists before rebooting:
          efibootmgr -v
      Entry creation is machine-specific (Limine, dual-boot chainloading):
      see the host README under nixos-config/.

  [ ] Where applicable, set the first boot generation from inside the new
      system so it matches the full configuration:
          sudo cp -r $repo /mnt/tmp/
          sudo nixos-enter --root /mnt -c "nixos-rebuild boot --flake /tmp/$repo_base#$host"

  [ ] Reboot into the installed system, then run the first Home Manager
      switch:
          nix run github:rytswd/nix-config#hm -- switch
      (or nix run .#hm -- switch from a fresh clone)

  [ ] Degraded install only: install a credential and rebuild WITHOUT the
      stub override -- docs/runbooks/credential-bootstrap.org. Nothing
      else changes.

  [ ] Machine-specific tail (Secure Boot, firmware walkthroughs): the host
      README under nixos-config/.
EOF

printf '\ninstall: done -- %s install flow for %s.\n' "$verdict" "$host"
if [ "$verdict" != full ]; then
    printf 'install: degraded build warnings will name the missing pieces; upgrade per docs/runbooks/credential-bootstrap.org.\n'
fi
if [ "$dry_run" = 1 ]; then
    printf 'install: this was a dry run -- no disks were touched, nothing was installed.\n'
fi
