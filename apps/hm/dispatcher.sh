# shellcheck shell=bash
#
# `hm` dispatcher -- resolves which Home Manager profile applies on the
# current host/user and forwards to `home-manager <cmd> --flake <dir>#<profile>`.
#
# Edit the case statements in `resolve_profile` to add a new host or
# adjust precedence. The map is intentionally explicit; no automatic
# attribute introspection so behaviour is obvious from `git blame`.

set -euo pipefail

host="$(hostname -s)"
user="$(id -un)"

###----------------------------------------
##  Profile map
#------------------------------------------
# First match wins. Add new hosts here as their homeConfigurations land.
# Entries marked TODO refer to homeConfigurations that do not yet exist.
resolve_profile() {
    local target="$1"
    case "$target" in
        # Exact <user>-<host> / <host>-<user> matches
        ryota-asus-rog-zephyrus-g14-2024) echo "ryota@asus-rog-zephyrus-g14-2024"; return 0 ;;
        # TODO: ryota-asus-rog-flow-z13-2025) echo "ryota@asus-rog-flow-z13-2025"; return 0 ;;
        # TODO: ryota-mbp-m1-max)              echo "ryota@mbp-m1-max"; return 0 ;;
        # TODO: ryota-mbp-m5-max)              echo "ryota@mbp-m5-max"; return 0 ;;
    esac
    case "$target" in
        # Host-only matches
        asus-rog-zephyrus-g14-2024) echo "ryota@asus-rog-zephyrus-g14-2024"; return 0 ;;
    esac
    case "$target" in
        # Glob fallbacks
        # Coder / devspace workspaces: arch picked by the workspace
        # itself. The x86_64 profile is the default; aarch64 workspaces
        # should override via `home-manager switch --flake .#ryota@coder-aarch64`.
        coder-*)      echo "ryota@coder"; return 0 ;;
        *-devspace-*) echo "ryota@coder"; return 0 ;;
        *-utm)        echo ""; return 1 ;;  # TODO: utm profile
    esac
    # No common fallback yet -- explicit unknown.
    return 1
}

profile=""
for key in "$user-$host" "$host-$user" "$host"; do
    if profile="$(resolve_profile "$key")"; then
        break
    fi
    profile=""
done

if [ -z "$profile" ]; then
    printf 'hm: no profile mapped for host=%s user=%s\n' "$host" "$user" >&2
    printf 'hm: edit apps/hm/dispatcher.sh to add one.\n' >&2
    exit 1
fi

cmd="${1:-switch}"
shift || true

flake_dir="${FLAKE_DIR:-${PRJ_ROOT:-$PWD}}"

case "$cmd" in
    profile)
        printf 'host:    %s\n' "$host"
        printf 'user:    %s\n' "$user"
        printf 'profile: %s\n' "$profile"
        printf 'flake:   %s\n' "$flake_dir"
        ;;
    switch|build|news|generations|packages)
        exec nix --extra-experimental-features 'nix-command flakes' \
            run home-manager/master -- "$cmd" \
                --flake "$flake_dir#$profile" "$@"
        ;;
    *)
        printf 'hm: unknown subcommand: %s\n' "$cmd" >&2
        printf 'usage: hm [profile|switch|build|news|generations|packages]\n' >&2
        exit 2
        ;;
esac
