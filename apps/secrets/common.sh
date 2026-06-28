# shellcheck shell=bash
#
# Shared helpers for the `secrets-enroll` / `secrets-revoke` flake apps.
# Concatenated ahead of enroll.sh / revoke.sh by ./default.nix, so both
# entry points stay in lockstep without a runtime `source`. Nothing here
# runs at top level except strict mode and constants.
#
# Both apps mutate a LOCAL checkout of the private repo and stop at a
# local commit -- pushing (after reviewing the diff) stays a human action,
# always.
#
# Private-repo interface expected here (the authoritative description
# lives in docs/runbooks/secrets-enrolment.org):
#
#   - `.sops.yaml` at the checkout root, whose ephemeral-class creation
#     rule lists enrolled recipients between the sentinel comments below.
#   - Ephemeral-class sops files under `ephemeral/`.
#   - The enrolment registry at `ephemeral/registry.org` (created on
#     first enrolment if missing).

set -euo pipefail

###----------------------------------------
##  Constants -- the private-repo interface
#------------------------------------------
# The sentinel pair marks the ONLY region of `.sops.yaml` this tooling
# writes to. Editing YAML structurally (yq and friends) was rejected on
# purpose: `.sops.yaml` is a hand-maintained file full of anchors, aliases
# and comments, and every YAML round-tripper rewrites at least its layout.
# A fixed-format managed block edited line-by-line is exact, preserves the
# rest of the file byte-for-byte, and makes the diff trivially reviewable.
# The trade-off -- the private repo must carry the sentinels inside its
# ephemeral-class creation rule -- is part of the documented interface.
BEGIN_SENTINEL='# BEGIN ENROLLED-INSTANCE RECIPIENTS'
END_SENTINEL='# END ENROLLED-INSTANCE RECIPIENTS'

# Registry as org rather than yaml: it exists for humans to eyeball drift
# at a glance, the repo's documentation convention is org (tables render
# on any forge), and the row format is fixed by this tool so line-based
# edits need no parser either way. Append-only: revocation fills the
# Revoked column instead of deleting the row, so the registry's git
# history doubles as the enrolment audit log.
REGISTRY_RELPATH='ephemeral/registry.org'
EPHEMERAL_DIR='ephemeral'

# Set to 1 by the --dry-run flag in the entry points; every mutating
# helper below checks it after printing what it would do.
DRY_RUN=0

###----------------------------------------
##  Logging
#------------------------------------------
log() { printf 'secrets: %s\n' "$*"; }
warn() { printf 'secrets: warning: %s\n' "$*" >&2; }
die() {
    printf 'secrets: error: %s\n' "$*" >&2
    exit 1
}

###----------------------------------------
##  Input validation
#------------------------------------------
# Names end up in YAML comments, org table rows and grep patterns, so the
# charset is restricted to make every later match exact rather than
# escaped-and-hopeful.
validate_name() {
    case "$1" in
    '' | -* | *[!a-z0-9-]*)
        die "invalid instance name '$1' (want lowercase: [a-z0-9][a-z0-9-]*)"
        ;;
    esac
}

validate_age_recipient() {
    local r="$1"
    case "$r" in
    AGE-SECRET-KEY-*)
        # The single worst paste mistake possible here -- call it out
        # explicitly instead of a generic format error.
        die 'that is an age PRIVATE key -- never share it; pass the public recipient (age1...)'
        ;;
    age1*) ;;
    *)
        die "not an age recipient: '$r' (expected age1...)"
        ;;
    esac
    # Bech32 age recipients are 62 chars; leave slack but catch truncation.
    [ "${#r}" -ge 58 ] || die "age recipient looks truncated: '$r'"
}

###----------------------------------------
##  Private-repo discovery
#------------------------------------------
# Mirrors the `local.ghRoot` convention from
# user-config/modules/lib/paths.nix: `<ghRoot>/rytswd/nix-config-private`,
# with ghRoot defaulting to `$HOME/Coding/github.com` and the known
# per-host override `$HOME/src/github.com` (coder/devspace-class machines
# keep checkouts on the persistent volume). Never clones: enrolment is a
# deliberate, reviewed act against a checkout the operator already trusts.
locate_private_repo() {
    local explicit="${1:-}"
    if [ -n "$explicit" ]; then
        [ -d "$explicit/.git" ] || die "--private-repo $explicit is not a git checkout"
        printf '%s\n' "$explicit"
        return 0
    fi
    local candidate
    for candidate in \
        "$HOME/Coding/github.com/rytswd/nix-config-private" \
        "$HOME/src/github.com/rytswd/nix-config-private"; do
        if [ -d "$candidate/.git" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    die "no private-repo checkout found (looked under \$HOME/Coding/github.com and \$HOME/src/github.com for rytswd/nix-config-private) -- this tool never clones; clone it yourself or pass --private-repo <path>"
}

###----------------------------------------
##  Recipient derivation (NixOS-class targets)
#------------------------------------------
# `ssh-keyscan <host> | ssh-to-age` is the whole trick: the instance's own
# ed25519 host key doubles as its age identity, so nothing new needs to be
# generated or copied onto the target. ssh-to-age only understands
# ed25519, hence the explicit type filtering and the tailored error.
derive_recipient_from_ssh() {
    local target="$1"
    # ssh-keyscan wants a bare host: strip any user@ prefix, honour an
    # optional :port suffix (the common ssh-target shapes).
    local host="${target#*@}" port=""
    case "$host" in
    *:*)
        port="${host##*:}"
        host="${host%:*}"
        ;;
    esac
    local -a scan_cmd=(ssh-keyscan -T 10)
    if [ -n "$port" ]; then
        scan_cmd+=(-p "$port")
    fi
    scan_cmd+=("$host")
    local scan
    scan=$("${scan_cmd[@]}" 2>/dev/null) || true
    [ -n "$scan" ] || die "ssh-keyscan returned nothing from $host -- is it reachable and running sshd?"
    local ed25519_line
    ed25519_line=$(printf '%s\n' "$scan" | grep -m1 ' ssh-ed25519 ' || true)
    if [ -z "$ed25519_line" ]; then
        local types
        types=$(printf '%s\n' "$scan" | cut -d' ' -f2 | sort -u | tr '\n' ' ')
        die "no ed25519 host key on $host (offered: ${types}) -- ssh-to-age supports ed25519 only; enable an ed25519 host key on the target, or generate a user-level key there with age-keygen and pass it via --age-key"
    fi
    printf '%s\n' "$ed25519_line" | ssh-to-age
}

###----------------------------------------
##  Mutation plumbing
#------------------------------------------
# Every file change goes through here: the exact unified diff is printed
# BEFORE anything is written, and --dry-run stops after the printing.
apply_file_mutation() {
    local label="$1" target="$2" newfile="$3"
    local old="$target"
    [ -e "$old" ] || old=/dev/null
    log "planned change to ${label}:"
    local rc=0
    diff -u --label "a/${label}" --label "b/${label}" "$old" "$newfile" || rc=$?
    [ "$rc" -le 1 ] || die "diff failed on ${label}"
    if [ "$rc" -eq 0 ]; then
        log "  (no change)"
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        log "[dry-run] not writing ${label}"
        rm -f "$newfile"
    else
        mkdir -p "$(dirname "$target")"
        mv "$newfile" "$target"
        log "wrote ${label}"
    fi
}

###----------------------------------------
##  .sops.yaml sentinel-block editing
#------------------------------------------
check_sentinel_block() {
    local file="$1"
    [ -f "$file" ] || die ".sops.yaml not found at $file -- is this really the private checkout?"
    local begins ends
    begins=$(grep -cF "$BEGIN_SENTINEL" "$file" || true)
    ends=$(grep -cF "$END_SENTINEL" "$file" || true)
    if [ "$begins" -ne 1 ] || [ "$ends" -ne 1 ]; then
        die ".sops.yaml must contain exactly one '$BEGIN_SENTINEL' / '$END_SENTINEL' pair inside the ephemeral-class creation rule (found $begins/$ends) -- see docs/runbooks/secrets-enrolment.org for the expected layout"
    fi
    local bline eline
    bline=$(grep -nF "$BEGIN_SENTINEL" "$file" | cut -d: -f1)
    eline=$(grep -nF "$END_SENTINEL" "$file" | cut -d: -f1)
    [ "$bline" -lt "$eline" ] || die ".sops.yaml sentinel block is inverted (END before BEGIN)"
}

# Print only the lines between the sentinels.
sentinel_block_lines() {
    local file="$1" inside=0 line
    while IFS= read -r line; do
        case "$line" in
        *"$BEGIN_SENTINEL"*)
            inside=1
            continue
            ;;
        *"$END_SENTINEL"*)
            inside=0
            continue
            ;;
        esac
        if [ "$inside" -eq 1 ]; then
            printf '%s\n' "$line"
        fi
    done <"$file"
    return 0
}

# Insert `- <recipient> # <name> (enrolled <date>)` just before the END
# sentinel, copying the sentinel's own indentation so the YAML list stays
# aligned whatever nesting depth the private repo uses.
sops_yaml_add() {
    local file="$1" recipient="$2" name="$3" date="$4"
    check_sentinel_block "$file"
    if sentinel_block_lines "$file" | grep -qE "# ${name} \(enrolled "; then
        die "'.sops.yaml' already has an enrolled recipient named '${name}' -- revoke it first (recreated instance?)"
    fi
    if sentinel_block_lines "$file" | grep -qF "$recipient"; then
        die "recipient $recipient is already enrolled under another name -- check the registry"
    fi
    local tmp indent line
    tmp=$(mktemp)
    while IFS= read -r line; do
        case "$line" in
        *"$END_SENTINEL"*)
            indent="${line%%#*}"
            printf '%s- %s # %s (enrolled %s)\n' "$indent" "$recipient" "$name" "$date" >>"$tmp"
            ;;
        esac
        printf '%s\n' "$line" >>"$tmp"
    done <"$file"
    apply_file_mutation ".sops.yaml" "$file" "$tmp"
}

# Drop the block line(s) carrying `# <name> (enrolled ...)`. Lines outside
# the sentinels are never candidates, so a hostname that happens to appear
# elsewhere in the file is safe.
sops_yaml_remove() {
    local file="$1" name="$2"
    check_sentinel_block "$file"
    if ! sentinel_block_lines "$file" | grep -qE "# ${name} \(enrolled "; then
        die "no enrolled recipient named '${name}' in .sops.yaml -- check the registry for the actual name"
    fi
    local tmp inside=0 line
    tmp=$(mktemp)
    while IFS= read -r line; do
        case "$line" in
        *"$BEGIN_SENTINEL"*) inside=1 ;;
        *"$END_SENTINEL"*) inside=0 ;;
        esac
        if [ "$inside" -eq 1 ] && printf '%s\n' "$line" | grep -qE "# ${name} \(enrolled "; then
            continue
        fi
        printf '%s\n' "$line" >>"$tmp"
    done <"$file"
    apply_file_mutation ".sops.yaml" "$file" "$tmp"
}

###----------------------------------------
##  Registry editing
#------------------------------------------
# Row shape (fixed by this tool; matched exactly below):
#
#     | <name> | <recipient> | <created> | <revoked-or-empty> | <purpose> |
#
# An ACTIVE row is one with an empty Revoked column. Built by plain
# concatenation (no printf format) so the ERE backslashes survive intact.
registry_active_row_re() {
    printf '%s' '^\| '"$1"' \| [^|]+ \| [^|]+ \| \| '
}

registry_header() {
    cat <<'EOF'
#+title: Enrolled-instance registry

Machine-maintained by the =secrets-enroll= / =secrets-revoke= flake apps in the public config repo; see =docs/runbooks/secrets-enrolment.org= there for the lifecycle. Append-only: rows are never deleted, revocation fills the =Revoked= column, so this file plus its git history is the enrolment audit log. Any active row whose instance no longer exists is overdue for =secrets-revoke=.

| Name | Recipient | Created | Revoked | Purpose |
|------+-----------+---------+---------+---------|
EOF
}

registry_add() {
    local repo="$1" name="$2" recipient="$3" date="$4" purpose="$5"
    local file="$repo/$REGISTRY_RELPATH"
    local tmp
    tmp=$(mktemp)
    if [ -f "$file" ]; then
        if grep -qE "$(registry_active_row_re "$name")" "$file"; then
            die "registry already has an active entry for '${name}' -- revoke it first"
        fi
        cat "$file" >"$tmp"
    else
        log "registry $REGISTRY_RELPATH does not exist yet -- creating it"
        registry_header >"$tmp"
    fi
    printf '| %s | %s | %s | | %s |\n' "$name" "$recipient" "$date" "$purpose" >>"$tmp"
    apply_file_mutation "$REGISTRY_RELPATH" "$file" "$tmp"
}

registry_revoke() {
    local repo="$1" name="$2" date="$3"
    local file="$repo/$REGISTRY_RELPATH"
    if [ ! -f "$file" ]; then
        warn "registry $REGISTRY_RELPATH not found -- .sops.yaml and registry have drifted; fixing .sops.yaml only"
        return 0
    fi
    local row_re
    row_re=$(registry_active_row_re "$name")
    if ! grep -qE "$row_re" "$file"; then
        warn "no active registry row for '${name}' -- .sops.yaml and registry have drifted; fixing .sops.yaml only"
        return 0
    fi
    local tmp line
    tmp=$(mktemp)
    while IFS= read -r line; do
        if printf '%s\n' "$line" | grep -qE "$row_re"; then
            # Fill the (only) empty Revoked column; everything else in the
            # row is preserved byte-for-byte.
            line="${line/ | | / | ${date} | }"
        fi
        printf '%s\n' "$line" >>"$tmp"
    done <"$file"
    apply_file_mutation "$REGISTRY_RELPATH" "$file" "$tmp"
}

###----------------------------------------
##  Re-encryption + commit
#------------------------------------------
# `sops updatekeys` re-wraps each file's data key for the rule's current
# recipient set. It needs to UNWRAP first, so this must run on a machine
# that can already decrypt the ephemeral class -- in practice, a YubiKey
# machine. Note what it does NOT do: rotate the data key itself. A revoked
# instance that kept a copy of the old file can decrypt that copy forever;
# `sops rotate -i` is the remedy when the teardown was not friendly (the
# runbook covers when to bother).
run_updatekeys() {
    local repo="$1"
    local dir="$repo/$EPHEMERAL_DIR"
    if [ ! -d "$dir" ]; then
        warn "no $EPHEMERAL_DIR/ directory in the private checkout -- nothing to re-encrypt"
        return 0
    fi
    local f found=0
    while IFS= read -r f; do
        # Only touch real sops files; `sops updatekeys` on plaintext (or
        # the registry, if it ever matched) would just error out.
        if ! grep -q 'sops_version' "$f"; then
            warn "skipping $f (not a sops-encrypted file)"
            continue
        fi
        found=1
        log "running: sops updatekeys --yes $f"
        if [ "$DRY_RUN" -eq 1 ]; then
            log "[dry-run] skipped"
        else
            sops updatekeys --yes "$f"
        fi
    done < <(find "$dir" -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.env' \) | sort)
    if [ "$found" -eq 0 ]; then
        warn "no sops files under $EPHEMERAL_DIR/ -- recipients changed but nothing re-encrypted"
    fi
    return 0
}

# The commit must contain exactly this enrolment/revocation and nothing
# else, so the paths we touch have to start clean. The rest of the
# checkout may be dirty -- we only ever `git add` our own paths.
ensure_paths_clean() {
    local repo="$1"
    local dirty
    dirty=$(git -C "$repo" status --porcelain -- .sops.yaml "$EPHEMERAL_DIR" || true)
    if [ -n "$dirty" ]; then
        die "uncommitted changes under .sops.yaml / $EPHEMERAL_DIR/ in $repo -- commit or stash them first so this lands as one clean change:
$dirty"
    fi
}

commit_private_repo() {
    local repo="$1" subject="$2" body="$3"
    if [ "$DRY_RUN" -eq 1 ]; then
        log "[dry-run] would commit in $repo:"
        log "  $subject"
        return 0
    fi
    git -C "$repo" add -- .sops.yaml "$EPHEMERAL_DIR"
    git -C "$repo" commit --quiet -m "$subject" -m "$body"
    # NEVER push: the operator reviews the diff and pushes deliberately.
    log "committed $(git -C "$repo" rev-parse --short HEAD) in $repo (NOT pushed -- review and push yourself)"
}
