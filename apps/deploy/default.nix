# `deploy` flake app -- day-2 rebuild of a remote NixOS host over SSH.
#
#     nix run .#deploy -- <host> <ssh-target> [flags...]
#
# Thin wrapper over `nixos-rebuild switch --target-host`, per
# air/v0.1/remote-provisioning.org: the provisioner builds (it has the
# private-repo access and the horsepower) and pushes the closure; the
# target only receives and activates. The first install of a host goes
# through the sibling `provision` app instead.
#
# Deliberately not deploy-rs / colmena: a single-digit fleet doesn't need
# rollback orchestration or parallel deploys, and keeping this a one-line
# wrapper means nothing of value is lost if clan's flow later absorbs it
# (see air/v0.1/clan-adoption.org).
#
# `<self>` is the flake's own source (this very revision), so the deploy
# always applies the exact tree the app was evaluated from -- same pattern
# as the bootstrap app.
{ pkgs, self }:

let
  # Same derived host list as the provision app -- attrNames never forces
  # the configuration values, so this stays evaluable without the private
  # flake input.
  hosts = builtins.concatStringsSep " " (builtins.attrNames self.nixosConfigurations);

  deploy = pkgs.writeShellApplication {
    name = "deploy";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
      pkgs.nixos-rebuild
      # nixos-rebuild drives the target over plain ssh from PATH.
      pkgs.openssh
    ];
    # Inject the flake's own store path and the derived host list so the
    # script needs no nix evaluation of its own at runtime.
    text = ''
      FLAKE_REF="${self}"
      NIXOS_HOSTS="${hosts}"
      export FLAKE_REF NIXOS_HOSTS
    ''
    + builtins.readFile ./deploy.sh;
  };
in
{
  type = "app";
  program = "${deploy}/bin/deploy";
}
