# `provision` flake app -- first install of a remote NixOS host over SSH.
#
#     nix run .#provision -- <host> <ssh-target> [flags...]
#
# Thin wrapper over nixos-anywhere (disko partitioning + install in one
# shot), per air/v0.1/remote-provisioning.org: argument parsing, host
# validation, and exec -- no orchestration state. Anything stateful
# (instance lifecycles, IPs) stays in per-host READMEs.
#
# nixos-anywhere is invoked via `nix run github:nix-community/nixos-anywhere`
# rather than added as a flake input -- it is a provisioning-time tool on the
# provisioner only, not part of any closure, so pinning it here would only
# add lockfile churn.
#
# `<self>` is the flake's own source (this very revision), so the install
# always applies the exact tree the app was evaluated from -- same pattern
# as the bootstrap app.
{ pkgs, self }:

let
  # Host candidates come straight from the flake's nixosConfigurations attr
  # names -- no separate registry to drift. `attrNames` never forces the
  # configuration values, so evaluating this app stays possible on machines
  # that cannot fetch the private flake input.
  hosts = builtins.concatStringsSep " " (builtins.attrNames self.nixosConfigurations);

  provision = pkgs.writeShellApplication {
    name = "provision";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
      # For deriving the public half of a seeded host key (ssh-keygen) and
      # the SSH transport nixos-anywhere itself drives.
      pkgs.openssh
    ];
    # Inject the flake's own store path and the derived host list so the
    # script needs no nix evaluation of its own at runtime.
    text = ''
      FLAKE_REF="${self}"
      NIXOS_HOSTS="${hosts}"
      export FLAKE_REF NIXOS_HOSTS
    ''
    + builtins.readFile ./provision.sh;
  };
in
{
  type = "app";
  program = "${provision}/bin/provision";
}
