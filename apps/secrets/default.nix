# `secrets-enroll` / `secrets-revoke` flake apps -- lifecycle tooling for
# the ephemeral-class secret tier (see air/v0.1/secrets-host-enrolment.org
# and docs/runbooks/secrets-enrolment.org).
#
#     nix run .#secrets-enroll -- <name> <ssh-target>
#     nix run .#secrets-enroll -- <name> --age-key <recipient>
#     nix run .#secrets-revoke -- <name>
#
# Both operate on a LOCAL checkout of the private repo (located via the
# `local.ghRoot` convention, `--private-repo` to override; never cloned),
# print every planned mutation as a unified diff before applying it, and
# stop at a local `git commit` -- pushing stays a human action. `--dry-run`
# stops at the printing.
#
# Everything here is generic machine-class tooling: names, recipients and
# the registry live in the private repo only.
{ pkgs }:

let
  mkSecretsApp =
    name: entryPoint:
    let
      app = pkgs.writeShellApplication {
        inherit name;
        # The full mutation toolchain rides in the app's closure so a
        # YubiKey machine can run this without having sops / ssh-to-age
        # installed ambiently.
        runtimeInputs = [
          pkgs.coreutils
          pkgs.diffutils # `diff -u` previews of every file mutation
          pkgs.findutils
          pkgs.gnugrep
          pkgs.git
          pkgs.sops # `updatekeys` over the ephemeral-class files
          pkgs.ssh-to-age # ed25519 host key -> age recipient
          pkgs.openssh # `ssh-keyscan`
        ];
        # Shared helpers (repo discovery, sentinel-block editing, registry
        # append/update, updatekeys + commit) are concatenated ahead of
        # each entry point so the two apps cannot drift apart, without a
        # runtime `source` of a second store path.
        text = builtins.readFile ./common.sh + builtins.readFile entryPoint;
      };
    in
    {
      type = "app";
      program = "${app}/bin/${name}";
    };
in
{
  secrets-enroll = mkSecretsApp "secrets-enroll" ./enroll.sh;
  secrets-revoke = mkSecretsApp "secrets-revoke" ./revoke.sh;
}
