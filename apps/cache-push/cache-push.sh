# shellcheck shell=bash
#
# `cache-push` -- push built closures to the self-hosted binary cache.
# See ./default.nix for the wiring rationale (and the niks3 CLI interface
# verification note) and docs/runbooks/binary-cache.org for the operational
# picture: read/write paths, who holds the token, push-after-build habit.

set -euo pipefail

usage() {
    cat >&2 <<EOF
usage: nix run .#cache-push -- [options] <store-path|installable...>

  <store-path|installable>
                /nix/store paths and existing paths (e.g. ./result) are
                pushed as-is after symlink resolution; anything else is
                treated as a flake installable and resolved via
                'nix build --no-link --print-out-paths' (a no-op when the
                closure is already built locally)

options:
  --dry-run     print the fully-resolved niks3 command and exit without
                connecting anywhere

Any other flag is passed through to 'niks3 push' verbatim.

environment (the niks3 CLI's own variables -- where the values live is
documented in docs/runbooks/binary-cache.org):
  NIKS3_SERVER_URL       niks3 server endpoint (write path); required
  NIKS3_AUTH_TOKEN_FILE  path to the API token file; may be omitted when the
                         token sits at \$XDG_CONFIG_HOME/niks3/auth-token or
                         an --auth-token-* flag is passed through
EOF
}

###----------------------------------------
##  Argument parsing
#------------------------------------------
if [ $# -ge 1 ] && { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
    usage
    exit 0
fi
if [ $# -lt 1 ]; then
    usage
    exit 2
fi

# Value-taking flags must consume their value here, or it would be misread
# as a store path below. The list mirrors the niks3 push flag set verified
# in ./default.nix; Go's flag package also accepts the --flag=value form,
# which needs no special handling.
dry_run=false
token_flag_passed=false
server_url_flag=""
passthrough=()
args=()
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            dry_run=true
            shift
            ;;
        # The niks3 CLI accepts the token via these flags too; when any of
        # them is present the environment check below would be wrong noise.
        --auth-token | --auth-token-path | --auth-token-script)
            if [ $# -lt 2 ]; then
                printf 'cache-push: %s requires a value\n' "$1" >&2
                exit 2
            fi
            token_flag_passed=true
            passthrough+=("$1" "$2")
            shift 2
            ;;
        --auth-token=* | --auth-token-path=* | --auth-token-script=*)
            token_flag_passed=true
            passthrough+=("$1")
            shift
            ;;
        --server-url)
            if [ $# -lt 2 ]; then
                printf 'cache-push: %s requires a value\n' "$1" >&2
                exit 2
            fi
            server_url_flag="$2"
            passthrough+=("$1" "$2")
            shift 2
            ;;
        --server-url=*)
            server_url_flag="${1#--server-url=}"
            passthrough+=("$1")
            shift
            ;;
        --max-concurrent-uploads | --pin | --client-cert | --client-key | --ca-cert)
            if [ $# -lt 2 ]; then
                printf 'cache-push: %s requires a value\n' "$1" >&2
                exit 2
            fi
            passthrough+=("$1" "$2")
            shift 2
            ;;
        --*)
            passthrough+=("$1")
            shift
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

if [ ${#args[@]} -eq 0 ]; then
    printf 'cache-push: no store paths or installables given\n' >&2
    usage
    exit 2
fi

###----------------------------------------
##  Environment checks
#------------------------------------------
# The write-path server endpoint is deliberately not hardcoded: it is not
# yet decided (air/v0.1/binary-cache-niks3.org History), and even once it
# is, it remains private infrastructure this public repo only consumes.
# NIKS3_SERVER_URL is the niks3 CLI's own variable; failing here (rather
# than letting the CLI fail mid-flight) gives a pointer to the runbook.
server_url="${server_url_flag:-${NIKS3_SERVER_URL:-}}"
if [ -z "$server_url" ]; then
    printf 'cache-push: NIKS3_SERVER_URL is not set (and no --server-url given)\n' >&2
    printf 'cache-push: it must point at the niks3 write-path server endpoint;\n' >&2
    printf 'cache-push: see docs/runbooks/binary-cache.org for where to find it\n' >&2
    exit 1
fi

# Token resolution mirrors the niks3 CLI's own order: an explicit
# --auth-token-* flag wins, then NIKS3_AUTH_TOKEN_FILE, then the XDG
# default. Only the "nothing at all" case is caught here, again for the
# runbook pointer.
if ! $token_flag_passed; then
    if [ -n "${NIKS3_AUTH_TOKEN_FILE:-}" ]; then
        if [ ! -r "$NIKS3_AUTH_TOKEN_FILE" ]; then
            printf 'cache-push: NIKS3_AUTH_TOKEN_FILE points at an unreadable path: %s\n' \
                "$NIKS3_AUTH_TOKEN_FILE" >&2
            exit 1
        fi
    elif [ ! -r "${XDG_CONFIG_HOME:-$HOME/.config}/niks3/auth-token" ]; then
        printf 'cache-push: no API token found\n' >&2
        printf 'cache-push: set NIKS3_AUTH_TOKEN_FILE (or place the token at\n' >&2
        printf 'cache-push: %s);\n' "${XDG_CONFIG_HOME:-$HOME/.config}/niks3/auth-token" >&2
        printf 'cache-push: see docs/runbooks/binary-cache.org for who holds it\n' >&2
        exit 1
    fi
fi

###----------------------------------------
##  Nix config for nested invocations
#------------------------------------------
# The inner `nix run github:Mic92/niks3` (and any `nix build` resolution
# below) needs flakes enabled in its own right -- CLI flags don't propagate
# to child nix processes, NIX_CONFIG does. accept-flake-config picks up this
# flake's substituters non-interactively. Append any pre-set NIX_CONFIG so
# we don't clobber it.
NIX_CONFIG="experimental-features = nix-command flakes pipe-operators
accept-flake-config = true
${NIX_CONFIG:-}"
export NIX_CONFIG

###----------------------------------------
##  Resolve arguments to store paths
#------------------------------------------
# niks3 push wants store paths. Existing filesystem paths (./result links,
# /nix/store paths) resolve locally; anything else goes through `nix build`,
# which is instant for closures that are already built -- this app pushes
# what exists, it is not a build frontend.
resolved=()
for arg in "${args[@]}"; do
    if [ -e "$arg" ]; then
        p="$(readlink -f "$arg")"
        case "$p" in
            /nix/store/*) resolved+=("$p") ;;
            *)
                printf 'cache-push: %s resolves outside the nix store: %s\n' "$arg" "$p" >&2
                exit 1
                ;;
        esac
    else
        mapfile -t outs < <(nix build --no-link --print-out-paths "$arg")
        if [ ${#outs[@]} -eq 0 ]; then
            printf 'cache-push: %s resolved to no store paths\n' "$arg" >&2
            exit 1
        fi
        resolved+=("${outs[@]}")
    fi
done

###----------------------------------------
##  Resolve and run
#------------------------------------------
cmd=(nix run github:Mic92/niks3 -- push)
cmd+=("${passthrough[@]}")
cmd+=("${resolved[@]}")

# Always print the resolved command -- same contract as provision/deploy:
# the app doubles as documentation of the underlying niks3 invocation, and
# thin wrappers earn trust by showing exactly what they run.
printf 'cache-push: server = %s\n' "$server_url"
printf 'cache-push: paths:\n'
printf '    %s\n' "${resolved[@]}"
printf 'cache-push: resolved command:\n    '
printf '%q ' "${cmd[@]}"
printf '\n'

if $dry_run; then
    printf 'cache-push: --dry-run, not executing\n'
    exit 0
fi

"${cmd[@]}"
