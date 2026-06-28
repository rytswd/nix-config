# shellcheck shell=bash
#
# `secrets-revoke` -- entry point. Helpers come from common.sh, which
# ./default.nix concatenates ahead of this file.

###----------------------------------------
##  Argument parsing
#------------------------------------------
usage() {
    cat <<'EOF'
usage: nix run .#secrets-revoke -- <name> [options]

Remove a previously-enrolled instance from the private repo's
ephemeral-class recipients. Part of every instance teardown, and of the
periodic registry-vs-reality sweep.

  <name>            the registry name used at enrolment
  --private-repo <path>
                    private checkout to operate on (default: the
                    `local.ghRoot` convention; never cloned)
  --dry-run         print every planned mutation, change nothing
  -h, --help        this text

What it does, in order, inside the private checkout:
  1. drop the instance's line from the .sops.yaml sentinel block
  2. fill the Revoked column of its active registry row (rows are
     never deleted -- the registry is the audit log)
  3. `sops updatekeys` every ephemeral-class sops file
  4. `git commit` the lot as one change (NEVER pushes)

Must run on a machine that can already decrypt the ephemeral class (in
practice: YubiKey present). Note: updatekeys re-wraps data keys for
future reads but does not rotate them -- if the instance was compromised
rather than simply retired, follow up with `sops rotate -i` on each
ephemeral-class file AND rotate the secret values themselves. See
docs/runbooks/secrets-enrolment.org.
EOF
}

name=""
private_repo=""

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --private-repo)
        [ $# -ge 2 ] || die "--private-repo needs a value"
        private_repo="$2"
        shift 2
        ;;
    --dry-run)
        DRY_RUN=1
        shift
        ;;
    --*)
        die "unknown flag: $1 (try --help)"
        ;;
    *)
        if [ -z "$name" ]; then
            name="$1"
        else
            die "unexpected argument: $1 (try --help)"
        fi
        shift
        ;;
    esac
done

[ -n "$name" ] || {
    usage >&2
    exit 2
}
validate_name "$name"

###----------------------------------------
##  Revoke
#------------------------------------------
repo=$(locate_private_repo "$private_repo")
log "private repo: $repo"
if [ "$DRY_RUN" -eq 1 ]; then
    log "dry-run: mutations are printed below but nothing is written"
fi

today=$(date +%Y-%m-%d)
ensure_paths_clean "$repo"
sops_yaml_remove "$repo/.sops.yaml" "$name"
registry_revoke "$repo" "$name" "$today"
run_updatekeys "$repo"
commit_private_repo "$repo" \
    "Revoke ephemeral-class recipient: $name" \
    "Revoked via the public repo's secrets-revoke app; ephemeral-class
files re-encrypted with sops updatekeys."

###----------------------------------------
##  Operator follow-ups (printed, not done)
#------------------------------------------
log "next steps:"
log "  1. review the diff in $repo, then push it yourself"
log "  2. if the instance lives on, drop 'local.secrets.tier' from its profile (or set local.secrets.enable = false)"
log "  3. if the teardown was not friendly: 'sops rotate -i' each ephemeral-class file and rotate the secret values"
