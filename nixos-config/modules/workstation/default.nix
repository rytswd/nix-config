# Workstation-flavoured system config that used to live in `core` but is
# really desktop/laptop-specific: NetworkManager, Dropbox firewall ports,
# docker+podman+libvirtd, geoclue + locale, system gpg-agent, nix-ld, and
# the uinput rule for xremap. Headless servers (e.g. hetzner-k8s) should
# NOT import this bundle.
{
  imports = [
    ./firewall.nix
    ./gnupg.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./udev.nix
    ./virtualisation.nix
  ];
}
