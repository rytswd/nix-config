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
export NIX_CONFIG

###----------------------------------------
##  Resolve profile
#------------------------------------------
# Arch decides the coder profile. An explicit profile can be passed as the
# first argument to override (e.g. `bootstrap-coder ryota@coder-aarch64`).
profile="${1:-}"
if [ -z "$profile" ]; then
    case "$(uname -m)" in
        x86_64)        profile="ryota@coder" ;;
        aarch64|arm64) profile="ryota@coder-aarch64" ;;
        *)
            printf 'bootstrap: unsupported arch: %s\n' "$(uname -m)" >&2
            printf 'bootstrap: pass a profile explicitly, e.g. ryota@coder\n' >&2
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
# `-b backup` renames any pre-existing, unmanaged dotfiles that would
# otherwise make the first activation fail on a fresh workspace.
exec nix \
    --extra-experimental-features 'nix-command flakes pipe-operators' \
    --accept-flake-config \
    run home-manager/master -- switch \
        --flake "$flake_ref#$profile" \
        -b backup \
        "${@:2}"
