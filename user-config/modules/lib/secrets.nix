# Shared toggles for SOPS-backed secret handling.
#
# Most hosts decrypt secrets at HM activation via sops-nix (real age key
# from a YubiKey + the private repo). Some hosts have no key at all -- most
# notably SSH-only coder / devspace workspaces -- where any `sops.secrets`
# or `sops.templates` definition makes activation fail with a decryption
# error. And some hosts sit in between: trusted enough to hold *some*
# secrets but physically unable to present a YubiKey (remote workspaces,
# cloud instances), enrolled with a per-instance key via the enrolment
# tooling in the private repo. See air/v0.1/secrets-host-enrolment.org and
# docs/runbooks/secrets-enrolment.org for the full lifecycle.
#
# That middle class maps onto the private repo's two secret classes:
#
#   - core class (`core/**`): encrypted to YubiKey recipients only.
#   - ephemeral class (`ephemeral/**`): encrypted to YubiKey recipients
#     PLUS the currently-enrolled instance keys.
#
# Module gating contract -- modules that define secrets but can be imported
# on hosts without the matching key wrap those definitions in:
#
#   - `lib.mkIf config.local.secrets.coreAvailable` for core-class
#     secrets (e.g. vcs/git/yubikey's key stubs, vcs/jj's config
#     template), falling back or simply staying absent without;
#   - `lib.mkIf config.local.secrets.ephemeralAvailable` for
#     ephemeral-class secrets (currently just shell/atuin's sync config),
#     with a non-secret fallback.
#
# Modules that are simply never imported on keyless hosts don't need to
# gate anything.
#
# Host knobs:
#
#     local.secrets.enable = false;       # keyless: no secrets at all
#     local.secrets.tier = "ephemeral";   # enrolled instance key only
#
# Shape rationale: `tier` is an enum rather than a second bool because a
# host holds exactly one kind of key -- YubiKey-derived ("full"), enrolled
# per-instance ("ephemeral"), or none (`enable = false`). A second bool
# (`ephemeralOnly`-style) would add a meaningless fourth state and read as
# a double negative at every gate, while collapsing everything into one
# three-value enum would break the existing `enable = false` host configs
# for no gain. `enable = false` keeps trumping `tier`, and both derived
# flags below default to following `enable`, so every existing host (and
# the coder profile) behaves exactly as before without touching anything.
#
# This option set lives in `lib/` and is pulled in by
# `security/sops-nix.nix`, so it is in scope on every host that imports
# the security bundle (which is also where the `sops.*` options themselves
# come from).
{ config, lib, ... }:
{
  options.local.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether SOPS-backed secret handling is available on this host at
        all. Set to false on hosts without any decryption key (e.g.
        SSH-only coder workspaces) so secret-defining modules fall back
        to non-secret configuration instead of failing at activation.
      '';
      example = false;
    };

    tier = lib.mkOption {
      type = lib.types.enum [
        "full"
        "ephemeral"
      ];
      default = "full";
      description = ''
        Which class of decryption key this host holds. Only meaningful
        while `enable` is true:

        - "full": a YubiKey-derived age key; every secret class
          decrypts. The default, and what all long-lived personal
          machines use.
        - "ephemeral": a per-instance key enrolled via the private
          repo's enrolment tooling; only ephemeral-class secrets
          decrypt, and core-class modules fall back exactly as if
          secrets were disabled.
      '';
      example = "ephemeral";
    };

    # The derived flags are options (not bare `let` helpers) so the gates
    # read identically everywhere and show up in documentation; readOnly
    # because they are facts computed from `enable` + `tier`, never set.
    coreAvailable = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = ''
        Read-only: whether core-class (YubiKey-only) secrets can be
        decrypted on this host. Modules defining core-class secrets gate
        on this, never on `enable` directly.
      '';
    };
    ephemeralAvailable = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = ''
        Read-only: whether ephemeral-class secrets can be decrypted on
        this host. True for both tiers -- YubiKeys remain recipients on
        every ephemeral-class file, so a "full" host decrypts them too.
        Modules defining ephemeral-class secrets gate on this.
      '';
    };
  };

  config.local.secrets = {
    coreAvailable = config.local.secrets.enable && config.local.secrets.tier == "full";
    ephemeralAvailable = config.local.secrets.enable;
  };
}
