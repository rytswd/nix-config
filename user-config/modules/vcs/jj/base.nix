# jj base UX -- aliases, ui, revset/template aliases, remote tracking --
# identical on every machine class; only identity differs per class.
# Deliberately lean (no packages, no secrets machinery) so profiles that
# don't want the full vcs bundle can import just this file.
#
# Load-order contract (jj reads config.toml first, then conf.d/*.toml in
# alphabetical order -- later wins on key collisions):
#
#   config.toml                  identity sliver: sops-rendered, core-gated
#                                (personal machines only; see ./default.nix)
#   conf.d/00-base.toml          this module's payload, first in conf.d by
#                                construction of the 00- prefix
#   conf.d/allowed-signers.toml  signature-verification registry (private
#                                repo, distributed to every class)
#   conf.d/work-machine.toml     work-class identity + ssh signing (private
#                                repo, work-class machines only)
#
# The contract that keeps these composable: base carries ZERO identity keys
# (user.*, signing.*) -- loading after config.toml, any such key here would
# silently override the sops-rendered identity -- and the identity files
# carry zero UX keys, or per-class UX would diverge again. Each file owns
# disjoint keys; alphabetical order only matters for conf.d filenames, never
# for resolving a collision.
{ ... }:
{
  xdg.configFile."jj/conf.d/00-base.toml".source = ./base.toml;
}
