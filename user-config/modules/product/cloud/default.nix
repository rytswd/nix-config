# Vendor cloud CLIs and IaC tooling. Bundle auto-imports the ones I want on
# every host. Single-platform CLIs I rarely touch (e.g. ./azure.nix) are
# opt-in.
{
  imports = [
    ./aws.nix
    ./fly.nix
    ./gcp.nix
    ./hetzner.nix
    ./terraform.nix
    # NOTE: ./azure.nix is intentionally NOT imported here — opt-in per host.
  ];
}
