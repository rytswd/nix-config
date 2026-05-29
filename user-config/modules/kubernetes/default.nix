{
  imports = [
    ./kubernetes.nix
    ./cncf.nix
    # NOTE: ./kubernetes-extra.nix is intentionally NOT imported here — opt-in per host.
  ];
}
