# shellcheck shell=bash
#
# `bootstrap` -- one-shot standalone Home Manager setup for coder/devspace
# workspaces. See ./default.nix for how this is wired and invoked.
#
# FLAKE_REF is injected by default.nix (the flake's own source path), so the
# switch builds from the same revision this app was evaluated from.

set -euo pipefail

flake_ref="${FLAKE_REF:?bootstrap: FLAKE_REF not set (run via the flake app)}"

###----------------------------------------
##  Nix config for nested invocations
#------------------------------------------
# `home-manager switch` spawns its own child `nix` processes for the build
# and activation. CLI flags like `--extra-experimental-features` only apply
# to the process they're passed to -- they do NOT propagate to children, so
# a nested build fails with "experimental Nix feature 'flakes' is disabled"
# even when the outer command had the flag.
#
# NIX_CONFIG is read by every nix process in this environment, so setting it
# here enables flakes (and the flake's binary caches) for the whole tree of
# nested invocations. Append any pre-set NIX_CONFIG so we don't clobber it.
NIX_CONFIG="experimental-features = nix-command flakes pipe-operators
accept-flake-config = true
${NIX_CONFIG:-}"

###----------------------------------------
##  GitHub auth for nix's fetchers (best-effort)
#------------------------------------------
# On a shared coder/devspace workspace the egress IP can hit GitHub's
# unauthenticated API rate limit during a cold bootstrap (many `github:`
# inputs), and any *private* flake input (e.g. nix-config-private, or
# swapdir while its repo is private) needs a credential to fetch over HTTPS
# -- there is no SSH key here. `gh` is authenticated as the workspace owner,
# so reuse its token via nix's `access-tokens`. This is the per-machine
# selectivity knob: laptops keep `git+ssh` (their SSH keys); only this
# coder entrypoint switches private fetches to authenticated HTTPS.
#
# Entirely best-effort: if `gh` is absent or logged out the token is empty
# and we proceed unauthenticated -- public inputs still resolve.
if command -v gh >/dev/null 2>&1 && gh_token="$(gh auth token 2>/dev/null)" \
    && [ -n "$gh_token" ]; then
    NIX_CONFIG="access-tokens = github.com=$gh_token
${NIX_CONFIG}"
    printf 'bootstrap: using gh auth token for github.com fetches\n'
else
    printf 'bootstrap: no gh token; proceeding unauthenticated (public inputs only)\n'
fi

export NIX_CONFIG

###----------------------------------------
##  Resolve profile
#------------------------------------------
# Arch decides the coder profile. An explicit profile can be passed as the
# first argument to override (e.g. `bootstrap-coder ryota@coder-aarch64`).
profile="${1:-}"
if [ -z "$profile" ]; then
    case "$(uname -m)" in
        x86_64)        profile="coder" ;;
        aarch64|arm64) profile="coder-aarch64" ;;
        *)
            printf 'bootstrap: unsupported arch: %s\n' "$(uname -m)" >&2
            printf 'bootstrap: pass a profile explicitly, e.g. coder\n' >&2
            exit 1
            ;;
    esac
fi

printf 'bootstrap: flake   = %s\n' "$flake_ref"
printf 'bootstrap: profile = %s\n' "$profile"

###----------------------------------------
##  Pin pre-seeded profile as a GC root
#------------------------------------------
# Coder / devspace images often ship a pre-seeded nix profile. Pin it as its
# own GC root before home-manager takes over so its store paths survive the
# first garbage collection. Guarded so it's a safe no-op everywhere else.
seed="$(realpath "$HOME/.local/state/nix/profiles/profile" 2>/dev/null || true)"
if [ -n "$seed" ] && [ -e "$seed" ]; then
    printf 'bootstrap: pinning seed profile as GC root: %s\n' "$seed"
    rm -f "$HOME/.local/state/nix/profiles/seed-1-link" \
          "$HOME/.local/state/nix/profiles/seed"
    nix-store --add-root "$HOME/.local/state/nix/profiles/seed-1-link" -r "$seed"
    ln -sfn seed-1-link "$HOME/.local/state/nix/profiles/seed"
fi

###----------------------------------------
##  Switch
#------------------------------------------
# `-b <ext>` renames any pre-existing, unmanaged dotfiles (e.g. the ones a
# fresh coder image ships) out of the way instead of aborting the first
# activation.
#
# The extension is TIMESTAMPED rather than a fixed "backup": home-manager
# refuses to back a file up to an extension that already exists, so a fixed
# extension makes any re-run fail ("Existing file ...backup is in the way")
# if an earlier run already created `*.backup`. A unique extension per run
# sidesteps that entirely. Subsequent switches don't re-back-up files HM
# already manages, so this doesn't accumulate on every run.
#
# `--impure` lets the profile read the real $USER / $HOME via
# `builtins.getEnv`, so the config follows whichever user runs it instead
# of a hardcoded name (see user-config/ryota/coder.nix). home-manager
# forwards unknown flags like this through to its underlying nix build.
backup_ext="hm-bak-$(date +%Y%m%d-%H%M%S)"

exec nix \
    --extra-experimental-features 'nix-command flakes pipe-operators' \
    --accept-flake-config \
    run home-manager/master -- switch \
        --flake "$flake_ref#$profile" \
        -b "$backup_ext" \
        --impure \
        "${@:2}"
