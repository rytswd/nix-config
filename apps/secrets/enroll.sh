# shellcheck shell=bash
#
# `secrets-enroll` -- entry point. Helpers come from common.sh, which
# ./default.nix concatenates ahead of this file.

###----------------------------------------
##  Argument parsing
#------------------------------------------
usage() {
    cat <<'EOF'
usage: nix run .#secrets-enroll -- <name> <ssh-target> [options]
       nix run .#secrets-enroll -- <name> --age-key <recipient> [options]

Enrol one keyless instance (remote workspace, cloud instance) as a
recipient of the private repo's ephemeral-class secrets. YubiKey-backed
age remains the primary mechanism everywhere; this is the narrow second
tier for machines that can never see a YubiKey.

  <name>            registry name for the instance ([a-z0-9-], e.g. the
                    machine-class name plus a counter)
  <ssh-target>      NixOS-class target: [user@]host[:port]; the recipient
                    is derived from its ed25519 host key via
                    `ssh-keyscan | ssh-to-age`
  --age-key <r>     HM-standalone-class target with no system access: the
                    age1... recipient from `age-keygen` run on the target
                    (identity stays there at ~/.config/sops/age/keys.txt)
  --purpose <text>  registry Purpose column (default: "(unspecified)")
  --private-repo <path>
                    private checkout to operate on (default: the
                    `local.ghRoot` convention; never cloned)
  --dry-run         print every planned mutation, change nothing
  -h, --help        this text

What it does, in order, inside the private checkout:
  1. derive/validate the age recipient
  2. add it to the .sops.yaml ephemeral-class sentinel block
  3. append an active row to ephemeral/registry.org
  4. `sops updatekeys` every ephemeral-class sops file
  5. `git commit` the lot as one change (NEVER pushes)

Must run on a machine that can already decrypt the ephemeral class (in
practice: YubiKey present) -- updatekeys re-wraps each file's data key.
See docs/runbooks/secrets-enrolment.org for the full lifecycle.
EOF
}

name=""
ssh_target=""
age_key=""
private_repo=""
purpose="(unspecified)"

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --age-key)
        [ $# -ge 2 ] || die "--age-key needs a value"
        age_key="$2"
        shift 2
        ;;
    --purpose)
        [ $# -ge 2 ] || die "--purpose needs a value"
        purpose="$2"
        shift 2
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
        elif [ -z "$ssh_target" ]; then
            ssh_target="$1"
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
if [ -n "$age_key" ] && [ -n "$ssh_target" ]; then
    die "pass either an <ssh-target> or --age-key, not both"
fi
if [ -z "$age_key" ] && [ -z "$ssh_target" ]; then
    die "need an <ssh-target> (NixOS-class) or --age-key (HM-standalone-class); try --help"
fi

###----------------------------------------
##  Enrol
#------------------------------------------
repo=$(locate_private_repo "$private_repo")
log "private repo: $repo"
if [ "$DRY_RUN" -eq 1 ]; then
    log "dry-run: mutations are printed below but nothing is written"
fi

if [ -n "$age_key" ]; then
    recipient="$age_key"
    log "recipient (supplied via --age-key): $recipient"
else
    log "deriving age recipient from the ed25519 host key of $ssh_target ..."
    recipient=$(derive_recipient_from_ssh "$ssh_target")
    log "recipient (derived): $recipient"
fi
validate_age_recipient "$recipient"

today=$(date +%Y-%m-%d)
ensure_paths_clean "$repo"
sops_yaml_add "$repo/.sops.yaml" "$recipient" "$name" "$today"
registry_add "$repo" "$name" "$recipient" "$today" "$purpose"
run_updatekeys "$repo"
commit_private_repo "$repo" \
    "Enrol ephemeral-class recipient: $name" \
    "Recipient: $recipient
Purpose: $purpose

Enrolled via the public repo's secrets-enroll app; ephemeral-class
files re-encrypted with sops updatekeys."

###----------------------------------------
##  Operator follow-ups (printed, not done)
#------------------------------------------
log "next steps:"
log "  1. review the diff in $repo, then push it yourself"
log "  2. set 'local.secrets.tier = \"ephemeral\"' in the instance's profile"
if [ -n "$age_key" ]; then
    log "  3. keep the age identity at ~/.config/sops/age/keys.txt on the instance (HM sops-nix default)"
else
    log "  3. the instance decrypts via its SSH host key (sops.age.sshKeyPaths) -- nothing to copy"
fi
log "  4. remember: revoke on teardown -- 'nix run .#secrets-revoke -- $name'"
