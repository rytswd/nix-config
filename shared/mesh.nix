# Mesh identity -- which entry of `nix-config-private`'s `devices` registry
# describes THIS machine, keyed by `networking.hostName`.
#
# WHY A MAP RATHER THAN THE HOSTNAME
#   The registry is keyed by mesh name, and for the main laptop that name is
#   not its NixOS hostname: the mesh name predates the host directory here and
#   renaming it would churn the server's Syncthing device labels for nothing.
#   The private repo's `data/README.org` therefore tells consumers to name the
#   key literally instead of interpolating a hostname, and this file is the one
#   place in this repo that does that naming.
#
# WHY THIS IS NOT A LEAK
#   A registry KEY is a pointer, not a value. No WireGuard public key, mesh
#   address, or Syncthing device ID is written here -- or anywhere else in this
#   public repo; consumers read them at eval time from the private flake's
#   `devices` output. And only a machine's OWN key ever appears below, because
#   every consumer builds its peer list by self-exclusion (drop this machine,
#   keep the rest) rather than by naming peers -- so joining the mesh discloses
#   nothing about the other members. A machine's own name is already public
#   here: it has a host directory in `nixos-config/`.
#
# ABSENT MEANS NO MESH
#   A host with no entry below configures no mesh at all. That mirrors the
#   registry itself, where machines that have not joined are absent rather than
#   stubbed, and it is the same outcome a degraded build gets -- the public stub
#   (`stubs/nix-config-private`) makes `devices` an empty attrset, so even a
#   listed host quietly ends up mesh-less rather than half-configured.
#
# Plain attrset, not a module -- NixOS modules (`nixos-config/modules/vpn`) and
# Home Manager modules (`user-config/modules/file-management`) both read it and
# do not share a module system. Same reasoning as ./keys.nix.
{
  # Main laptop. A mesh leaf: its registry entry carries `wireguard.ip` (its
  # own /32) and a Syncthing device ID.
  asus-rog-flow-z13-2025 = "ryota-asus-flow-z13-2025";
}
