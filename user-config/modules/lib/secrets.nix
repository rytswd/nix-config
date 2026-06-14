# Shared toggle for SOPS-backed secret handling.
#
# Most hosts decrypt secrets at HM activation via sops-nix (real age key
# from a YubiKey + the private repo). Some hosts have no key at all -- most
# notably SSH-only coder / devspace workspaces -- where any `sops.secrets`
# or `sops.templates` definition makes activation fail with a decryption
# error.
#
# Modules that define secrets but are imported on keyless hosts (currently
# just shell/atuin, which comes in via the shell bundle) wrap those
# definitions in `lib.mkIf config.local.secrets.enable` and provide a
# non-secret fallback. A host opts out with:
#
#     local.secrets.enable = false;
#
# Modules that are simply not imported on keyless hosts (e.g. vcs/jj,
# vcs/git/yubikey -- config managed separately on coder) don't need to
# gate anything.
#
# This option lives in `lib/` and is pulled in by `security/sops-nix.nix`,
# so it is in scope on every host that imports the security bundle (which
# is also where the `sops.*` options themselves come from).
{ lib, ... }:
{
  options.local.secrets.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether SOPS-backed secret handling is available on this host.
      Set to false on hosts without a decryption key (e.g. SSH-only
      coder workspaces) so secret-defining modules fall back to
      non-secret configuration instead of failing at activation.
    '';
    example = false;
  };
}
