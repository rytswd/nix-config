# shellcheck shell=bash
#
# Credential preflight -- shared shell library deciding "full" vs "degraded"
# evaluation of this flake, before any build is attempted.
#
# The private input (`nix-config-private`) is a `git+ssh` flake input, so a
# *full* eval needs an SSH credential that can reach the private remote at
# eval time. This library detects what is available, in order of usefulness:
#
#   1. ssh-agent / on-disk identity that actually reaches the private remote
#   2. YubiKey FIDO2 resident keys (present but not yet usable -> guidance)
#   3. forge CLI token (`gh`) -- best-effort only, NEVER required; a token
#      helps HTTPS `github:` fetches (rate limits, private mirrors) but does
#      NOT satisfy the `git+ssh` private input, so it never upgrades the
#      verdict to "full"
#
# and emits a verdict: full eval, or degraded eval via the public stub at
# stubs/nix-config-private (see air/v0.1/private-input-stub.org and
# docs/runbooks/credential-bootstrap.org).
#
# Consumers: sourced by apps/bootstrap/bootstrap.sh (token lookup only --
# the coder profile never touches the private input), and run directly by
# the install runbook flow:
#
#     bash apps/lib/preflight.sh
#
# Everything is keyed off the remote URL, not a forge API, so moving the
# private repo off GitHub is a one-line change here (or set
# NIXCFG_PRIVATE_REMOTE in the environment).

###----------------------------------------
##  Configuration
#------------------------------------------
# Must match the `nix-config-private` URL in flake.nix (sans flake query
# params -- `git ls-remote` wants a plain git URL).
NIXCFG_PRIVATE_REMOTE="${NIXCFG_PRIVATE_REMOTE:-ssh://git@github.com/rytswd/nix-config-private}"

# The two equivalent degraded-eval overrides: local checkout, and the
# no-clone form over the GitHub tarball API (no SSH involved -- same trick
# the `treesitter-grammars` input relies on).
NIXCFG_STUB_OVERRIDE="--override-input nix-config-private path:./stubs/nix-config-private"
NIXCFG_STUB_OVERRIDE_NO_CLONE="--override-input nix-config-private 'github:rytswd/nix-config?dir=stubs/nix-config-private'"

###----------------------------------------
##  Detection primitives
#------------------------------------------
# Each probe answers one question via exit status; `preflight_report` does
# the talking. Kept separate so a future installer can script against the
# probes without the prose.

# Can the current SSH setup (agent identities and/or on-disk keys) reach the
# private remote? This is the only check that proves a *full* eval will work,
# so it probes the real remote rather than guessing from key files.
#
# BatchMode forbids interactive prompts (a preflight must never hang on a
# passphrase), ConnectTimeout bounds the offline case, and accept-new keeps a
# brand-new machine from failing on the unknown host key before the auth
# check even happens (first-use trust is acceptable for a read-only probe).
preflight_ssh_ok() {
    command -v git >/dev/null 2>&1 || return 1
    command -v ssh >/dev/null 2>&1 || return 1
    GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new' \
        git ls-remote --exit-code "$NIXCFG_PRIVATE_REMOTE" HEAD >/dev/null 2>&1
}

# Any evidence of YubiKey FIDO2 material? Prints what was found (one line)
# on success. Two tiers, both best-effort:
#   - resident keys already downloaded to ~/.ssh: the `ssh-keygen -K` naming
#     (`id_*_sk_rk*`) and this repo's own `id_yubikey_<serial>_auth` layout
#     (user-config/modules/vcs/git/yubikey.nix). `.pub` halves are excluded
#     -- Home Manager places those on every configured machine, with or
#     without the private halves.
#   - a key that is merely plugged in: `ykman` when available, else a USB
#     vendor match. No hard dependency on either tool.
preflight_yubikey_status() {
    local k
    for k in "$HOME"/.ssh/id_*_sk_rk* "$HOME"/.ssh/id_yubikey_*_auth; do
        [ -e "$k" ] || continue
        case "$k" in *.pub) continue ;; esac
        printf 'resident key on disk: %s\n' "$k"
        return 0
    done
    if command -v ykman >/dev/null 2>&1 && [ -n "$(ykman list 2>/dev/null)" ]; then
        printf 'connected: %s\n' "$(ykman list 2>/dev/null | head -n1)"
        return 0
    fi
    if command -v lsusb >/dev/null 2>&1 && lsusb 2>/dev/null | grep -qi yubico; then
        printf 'connected: YubiKey (via lsusb)\n'
        return 0
    fi
    return 1
}

# Forge CLI token, entirely best-effort: if `gh` is absent or logged out
# nothing is printed and the caller proceeds unauthenticated -- public
# inputs still resolve. This is the single home of the gh lookup; the
# bootstrap app consumes it instead of carrying its own copy.
preflight_gh_token() {
    command -v gh >/dev/null 2>&1 || return 1
    local token
    token="$(gh auth token 2>/dev/null)" || return 1
    [ -n "$token" ] || return 1
    printf '%s\n' "$token"
}

###----------------------------------------
##  Verdict
#------------------------------------------
# Runs the probes in order and prints a human verdict. Sets
# PREFLIGHT_VERDICT=full|degraded for scripted callers, and always returns 0
# -- a degraded machine is an expected state, not an error; the caller (or
# the human reading the output) decides what to do with it.
# shellcheck disable=SC2034  # PREFLIGHT_VERDICT is for callers, not read here
preflight_report() {
    local yk token
    printf 'preflight: private remote = %s\n' "$NIXCFG_PRIVATE_REMOTE"

    if preflight_ssh_ok; then
        PREFLIGHT_VERDICT=full
        printf 'preflight: ssh credential reaches the private remote\n'
        printf 'preflight: VERDICT = full eval possible; build without any override\n'
        return 0
    fi
    PREFLIGHT_VERDICT=degraded
    printf 'preflight: no usable ssh credential for the private remote\n'

    if yk="$(preflight_yubikey_status)"; then
        printf 'preflight: YubiKey FIDO2 -- %s\n' "$yk"
        printf 'preflight:   to activate it:  ssh-keygen -K   (downloads resident keys to CWD;\n'
        printf 'preflight:   move them to ~/.ssh, then ssh-add them and re-run this preflight)\n'
    else
        printf 'preflight: no YubiKey FIDO2 material detected\n'
    fi

    if token="$(preflight_gh_token)"; then
        # Deliberately not part of the verdict: a token serves HTTPS
        # `github:` fetches only, and the private input is git+ssh.
        printf 'preflight: gh token available (helps github: fetches / rate limits only)\n'
        : "$token"
    else
        printf 'preflight: no gh token (fine -- it is never required)\n'
    fi

    printf 'preflight: VERDICT = degraded eval; substitute the public stub:\n'
    printf 'preflight:   from a checkout:  %s\n' "$NIXCFG_STUB_OVERRIDE"
    printf 'preflight:   without a clone:  %s\n' "$NIXCFG_STUB_OVERRIDE_NO_CLONE"
    printf 'preflight: a degraded build announces itself via eval warnings; once a\n'
    printf 'preflight: credential is in place, rebuild WITHOUT the override -- nothing\n'
    printf 'preflight: else changes (docs/runbooks/credential-bootstrap.org).\n'
    return 0
}

###----------------------------------------
##  Direct execution
#------------------------------------------
# `bash apps/lib/preflight.sh` runs the report straight away -- the runbook
# entry point. When sourced (bootstrap), nothing executes.
if [ "${BASH_SOURCE[0]:-}" = "$0" ]; then
    set -euo pipefail
    preflight_report
fi
